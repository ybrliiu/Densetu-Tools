package Densetu::Tools::UpdateTimeTable::Country {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak confess/;
  use Class::Accessor::Lite new => 0;

  use HTML::TreeBuilder;
  use Record::Hash;
  use Densetu::Tools::Util qw/:DEFAULT get_data/;
  use Densetu::Tools::UpdateTimeTable::Player;

  {
    my %attributes = (
      name => undef,
      no   => undef,
    );

    Class::Accessor::Lite->mk_accessors(keys %attributes);

    sub new {
      my ($class, %args) = @_;
      my $self = {%attributes, %args};
      return bless $self, $class;
    }
  }

  sub parse {
    my ($self, $line) = @_;
    $self->{name} = $self->extract_name($line);
    $self->{no}   = $self->extract_no($line);
  }

  sub extract_name {
    my ($self, $line) = @_;
    my ($name) = ($line =~ /size=4><B>(.*?)\(税率/);
    return $name;
  }

  sub extract_no {
    my ($self, $line) = @_;
    my ($no) = ($line =~ /\.\/ranking\.cgi\?mode=C_RAN&con_no=(.*?)>武将一覧/);
    return $no;
  }

  sub member_url {
    my ($self) = @_;
    return "http://densetu.sakura.ne.jp/ranking.cgi?mode=C_RAN&con_no=@{[ $self->{no} ]}";
  }

  sub get_member_info {
    my ($self) = @_;
    get_data($self->member_url);
  }

  sub create_member_info {
    my ($self) = @_;

    my $record = Record::Hash->new(file => UPDATE_TIME_TABLE_PATH())->open('LOCK_EX');
    my $member_line = $self->_extract_member_line;
    my @player_rows = @{ $self->_parse_parse_battle_log_row($member_line) };

    my %match_players = map {
      my $tag = $_;
      my $parse_battle_log = $self->_parse_parse_battle_log($tag);
      my $player_name = $parse_battle_log->[0];
      my $player      = $self->_get_player($player_name, $record);
      $player->set_country_member_info(@$parse_battle_log);
      $player_name => $player;
    } @player_rows;

    $record->close();
    return \%match_players;
  }

  # 取得したhtmlデータから、武将一覧が乗っている部分を取り出す(tableだがhtml側では1行になっている)
  sub _extract_member_line {
    my ($self) = @_;
    my $member_info = $self->get_member_info;
    my @lines = split /\n/, $member_info;
    my ($member_line) = grep $_ =~ /<TH>名前<\/TH><TH>武力<\/TH><TH>知力<\/TH>/, @lines;
    return $member_line;
  }

  # 武将一覧が乗っているtableデータを行(trタグ)毎に分ける
  sub _parse_parse_battle_log_row {
    my ($self, $member_line) = @_;
    my $html = HTML::TreeBuilder->new();
    my $root = $html->parse($member_line);
    my @tr   = $root->find('tr');
    shift @tr;
    return \@tr;
  }

  # 武将情報が乗っている行(trタグ)を解析して武将情報を得る
  sub _parse_parse_battle_log {
    my ($self, $tag) = @_;
    my @parse_battle_log = map {
      my ($link) = $_->find('a');
      $link ? $link->as_text : $_->as_text;
    } $tag->find('td');
    shift @parse_battle_log;
    return \@parse_battle_log;
  }

  sub _get_player {
    my ($self, $player_name, $record) = @_;

    my $player;
    if ( $record->exists($player_name) ) {
      $player = $record->find($player_name);
      $player->country($self->{name}) if $player->country ne $self->{name};
    } else {
      say "不明な武将データが発見されました($player_name)。新規武将データを作成します。";
      $player = 'Densetu::Tools::UpdateTimeTable::Player'->new(
        name    => $player_name,
        country => $self->{name},
        time    => '????',
      );
      $player->name($player_name);
      $record->add($player_name => $player);
    }
    return $player;
  }

}

1;
