package Densetu::Tools::UpdateTimeTable {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak confess/;

  use Record::Hash;
  use Densetu::Tools::Util qw/get_data/;
  use Densetu::Tools::UpdateTimeTable::Player;
  use Densetu::Tools::UpdateTimeTable::Country;

  use constant RECORD => Record::Hash->new(File => 'etc/record/player_map_log.dat');
  
  sub _extract_update_time {
    my ($class, $map_log) = @_;
    my @lines = split /\n/, $map_log;
    my @player_infomations = grep $_ =~ /【建国】/ && $_ !~ /年/ || $_ =~ /\[仕官\]/, @lines;
    return \@player_infomations;
  }

  sub new_update_time_table {
    my ($class) = @_;

    my $map_log = get_data('http://densetu.sakura.ne.jp/map.cgi');
    my $player_info = $class->_extract_update_time($map_log);

    # プレイヤーオブジェクト生成
    my %players = map {
      my $line = $_;
      my $player = 'Densetu::Tools::UpdateTimeTable::Player'->new();
      $player->parse($line);
      $player->name => $player;
    } @$player_info;

    # リセット直後のみ更新時間データを生成
    if ($map_log =~ /ゲームプログラムを開始しました。/) {
      my $record = RECORD;
      $record->Data(\%players);
      $record->make;
    } else {
      croak 'ゲーム開始から時間が経ちすぎているようなので更新時間データの生成を中止します。'
    }

  }

  sub _extract_country_line {
    my ($class, $ranking_log) = @_;
    my @lines = split /\n/, $ranking_log;
    return grep $_ =~ /\.\/ranking\.cgi\?mode=C_RAN&con_no=(.*?)>武将一覧/, @lines;
  }

  sub create_country_list {
    my ($class) = @_;

    my $ranking_log = get_data('http://densetu.sakura.ne.jp/ranking.cgi');
    my @country_line = $class->_extract_country_line($ranking_log);

    my %countries = map {
      my $line = $_;
      my $country = 'Densetu::Tools::UpdateTimeTable::Country'->new();
      $country->parse($line);
      $country->name => $country;
    } @country_line;
    return \%countries;
  }

  sub update_player_country {
    my ($class, %args) = @_;

    my $countries = $class->create_country_list();

    for my $country_name (values %args) {
      my $country = exists $countries->{$country_name} ? $countries->{$country_name} : croak "${country_name}という国は存在しません.";
      $country->create_member_info();
    }
  }

  sub output_mix_table {
    my ($class, %args) = @_;
    for (qw/country1 country2/) {
      croak "$_\が指定されていません" unless exists $args{$_}
    }

    $class->update_player_country(%args);

    # 出力する武将を集める
    my %people = (
      country1 => 0,
      country2 => 0,
    );
    my $record = RECORD->open;
    my @collect = $record->map(sub {
      my ($key, $value) = @_;
      if ($value->country eq $args{country1}) {
        $people{country1}++;
        $value->mark('○');
      } elsif ($value->country eq $args{country2}) {
        $people{country2}++;
        $value->mark('●');
      } else {
        ()
      }
    });
    my @output = sort { $a->hour_sec <=> $b->hour_sec } @collect;

    my $result = "【$args{country2}戦更新表】\n";
    $result .= "○=$args{country1}($people{country1}人),●=$args{country2}($people{country2}人)\n\n";
    $result .= $_->update_time_table for @output;

    return $result;
  }

  sub output_table {
    my ($class, %args) = @_;
    croak "$_\が指定されていません" unless exists $args{country};

    $class->update_player_country(%args);

    my $record = RECORD->open;
    my @collect = $record->map( sub {
      my ($key, $value) = @_;
      $value->country eq $args{country} ? $value->mark('') : ();
    });
    my @output = sort { $a->hour_sec <=> $b->hour_sec } @collect;

    my $result = "【$args{country}更新表($#{collect}人)】\n\n";
    $result .= $_->update_time_table for @output;

    return $result;
  }

  sub add_player_from_line {
    my ($class, $line) = @_;
    my $player = Densetu::Tools::UpdateTimeTable::Player->new();
    $player->parse($line);
    my $record = RECORD->open('LOCK_EX');
    $record->Data->{$player->name} = $player;
    $record->close();
  }

  sub edit_player {
    my ($class, %args) = @_;
    for (qw/name time/) {
      confess "$_\が指定されていません" unless exists $args{$_}
    }

    my $record = RECORD->open("LOCK_EX");
    my $player = $record->find($args{name});
    $player->input_time($args{time});
    $record->close();

    say "$args{name}編集完了";
  }

}

1;

=encoding utf-8

=head1

=cut
