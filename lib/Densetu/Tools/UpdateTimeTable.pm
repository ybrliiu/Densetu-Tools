package Densetu::Tools::UpdateTimeTable {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak/;

  use Record::Hash;
  use Densetu::Tools::Util qw/:DEFAULT get_data/;
  use Densetu::Tools::UpdateTimeTable::Player;
  use Densetu::Tools::UpdateTimeTable::Country;
  use Time::Piece;

  use constant {
    MAP_LOG_URL     => 'http://densetu.sakura.ne.jp/map.cgi',
    JUDGE_DELAY_SEC => 240,
    MAX_DELAY_SEC   => 600,
    START_TIME_TO_CHECK_DELAY => 7,
    END_TIME_TO_CHECK_DELAY   => 1,
  };

  my $RECORD = Record::Hash->new(file => UPDATE_TIME_TABLE_PATH);
  
  sub _extract_update_time {
    my ($class, $map_log) = @_;
    my @lines = split /\n/, $map_log;
    my @parse_battle_logmations = grep $_ =~ /【建国】/ && $_ !~ /年/ || $_ =~ /\[仕官\]/, @lines;
    return \@parse_battle_logmations;
  }

  sub _extract_attack_log {
    my ($class, $map_log) = @_;
    my @lines = split /\n/, $map_log;
    my @parse_battle_logmations = grep $_ =~ /へ攻め込みました！/, @lines;
    return \@parse_battle_logmations;
  }

  sub _lines_to_players {
    my ($class, $lines) = @_;
    my @players = map {
      my $line = $_;
      my $player = Densetu::Tools::UpdateTimeTable::Player->new;
      $player->parse($line);
      $player;
    } @$lines;
    return \@players;
  }

  sub new_update_time_table {
    my ($class) = @_;

    my $map_log        = get_data(MAP_LOG_URL);
    my $parsed_map_log = $class->_extract_update_time($map_log);

    my $players      = $class->_lines_to_players($parsed_map_log);
    my %players_hash = map { $_->name => $_ } @$players;

    # リセット直後のみ更新時間データを生成
    if ($map_log =~ /ゲームプログラムを開始しました。/) {
      my $record = $RECORD;
      $record->data(\%players_hash);
      $record->make;
    } else {
      croak 'ゲーム開始から時間が経ちすぎているようなので更新時間データの生成を中止します。'
    }

  }

  sub update_time_from_map_log {
    my ($class) = @_;

    my $map_log = get_data(MAP_LOG_URL);
    my $parsed_map_log = $class->_extract_attack_log($map_log);

    my $players = $class->_lines_to_players($parsed_map_log);
    my $record  = $RECORD->open('LOCK_EX');
    for my $new_player (@$players) {

      my $old_player = eval {
        $record->find( $new_player->name );
      };
      if (my $e = $@) {
        warn "国名の取得に失敗しました (@{[ $new_player->name ]}, @{[ $new_player->country ]})";
        my $countries    = $class->create_country_list;
        my $country_name = $class->_search_coutry($countries, $new_player->country);
        $new_player->reparse( $country_name );
        $old_player = $record->find( $new_player->name );
      }

      if ( $new_player->time->hour <= END_TIME_TO_CHECK_DELAY
        || $new_player->time->hour >= START_TIME_TO_CHECK_DELAY )
      {
        $class->judge_delay(
          record     => $record,
          old_player => $old_player,
          new_player => $new_player,
        );
      }

    }
    $record->close();
  }

  sub judge_delay {
    my ($class, %args) = @_;
    my @args_name = qw/record old_player new_player/;
    for (@args_name) {
      croak "$_\が指定されていません" unless exists $args{$_};
    }
    my ($record, $old_player, $new_player) = map { $args{$_} } @args_name;

    my $delay_time = $new_player->min_sec - $old_player->min_sec;

    if ($delay_time > JUDGE_DELAY_SEC) {
        _warn_update_time($old_player, $new_player);
      $old_player->update_time( $new_player->time );
      $record->update($old_player->name => $old_player);
    }
    elsif ($delay_time < 0) {
      # 59分超えて0分以降になった場合
      if ( $new_player->min_sec + 3600 - $old_player->min_sec < MAX_DELAY_SEC ) {
        _warn_update_time($old_player, $new_player);
        $old_player->update_time( $new_player->time );
        $record->update($old_player->name => $old_player);
      }
      # 遅延判定を厳密にしていく
      elsif ( $new_player->min_sec - $old_player->origin_min_sec < JUDGE_DELAY_SEC ) {
        _warn_update_time($old_player, $new_player);
        $old_player->time( $new_player->time );
        $record->update($old_player->name => $old_player);
      }
      else {
        warn "異常な現象発生 (@{[ $new_player->name ]})";
      }
    }
  }

  sub _warn_update_time {
    my ($old_player, $new_player) = @_;
    warn "@{[ $old_player->name ]} の更新時間を@{[ $old_player->show_time ]}から@{[ $new_player->show_time ]}に変更しました。";
  }

  sub add_players_from_map_log {
    my ($class) = @_;

    my $map_log = get_data(MAP_LOG_URL);
    my $parsed_map_log = $class->_extract_update_time($map_log);
    return if @$parsed_map_log == 0;

    my $players = $class->_lines_to_players($parsed_map_log);
    my $record = $RECORD->open('LOCK_EX');
    for my $player (@$players) {
      warn "新しく@{[ $player->name ]}が追加されました ";
      $record->add($player->name => $player);
    }
    $record->close();

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

    my @countries = map {
      my $line = $_;
      my $country = 'Densetu::Tools::UpdateTimeTable::Country'->new();
      $country->parse($line);
      $country;
    } @country_line;
    return \@countries;
  }

  sub _search_coutry {
    my ($class, $countries, $country_name) = @_;
    for my $country (@$countries) {
      return $country->name if $country->name =~ $country_name;
    }
  }

  sub update_player_country {
    my ($class, %args) = @_;

    my $countries      = $class->create_country_list();
    my %countries_hash = map { $_->name => $_ } @$countries;

    for my $country_name (values %args) {
      my $country       = exists $countries_hash{$country_name} ? $countries_hash{$country_name} : croak "${country_name}という国は存在しません.";
      my $match_players = $country->create_member_info();
      $class->_delete_not_exists_player($country_name => $match_players);
    }

  }

  sub _delete_not_exists_player {
    my ($class, $country_name, $match_players) = @_;

    my $record = $RECORD->open('LOCK_EX');
    my %players = $record->map(sub {
      my ($key, $value) = @_;
      if ($country_name eq $value->country) {
        $key => $value;
      } else {
        ();
      }
    });

    # 国一覧にいなかった武将はとりあえず無所属にする
    for my $key (keys %players) {
      unless (exists $match_players->{$key}) {
        my $player = $record->find($key);
        $player->country('');
      }
    }

    $record->close();
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
    my $record = $RECORD->open;
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
    my @output = sort { $a->min_sec <=> $b->min_sec } @collect;

    my $result = "【$args{country2}戦更新表】\n";
    $result .= "○=$args{country1}($people{country1}人),●=$args{country2}($people{country2}人)\n\n";
    $result .= $_->update_time_table for @output;

    return $result;
  }

  sub output_table {
    my ($class, %args) = @_;
    croak "$_\が指定されていません" unless exists $args{country};

    $class->update_player_country(%args);

    my $record = $RECORD->open;
    my @collect = $record->map( sub {
      my ($key, $value) = @_;
      $value->country eq $args{country} ? $value->mark('') : ();
    });
    my @output = sort { $a->min_sec <=> $b->min_sec } @collect;

    my $result = "【$args{country}更新表(" . @output . "人)】\n\n";
    $result .= $_->update_time_table for @output;

    return $result;
  }

  sub add_player {
    my ($class, %args) = @_;
    for (qw/name time/) {
      croak "$_\が指定されていません" unless exists $args{$_}
    }

    my $record = $RECORD->open("LOCK_EX");
    my $player = 'Densetu::Tools::UpdateTimeTable::Player'->new(name => $args{name});
    $player->input_time($args{time});
    $record->add($args{name} => $player);
    $record->close();
  }

  sub add_player_from_line {
    my ($class, $line) = @_;
    my $player = 'Densetu::Tools::UpdateTimeTable::Player'->new();
    $player->parse($line);
    my $record = $RECORD->open('LOCK_EX');
    $record->add($player->name => $player);
    $record->close();
  }

  sub edit_player {
    my ($class, %args) = @_;
    for (qw/name time/) {
      croak "$_\が指定されていません" unless exists $args{$_}
    }

    my $record = $RECORD->open("LOCK_EX");
    my $player = $record->find($args{name});
    $player->input_time($args{time});
    $record->close();

    warn "$args{name}編集完了";
  }

}

1;

=encoding utf-8

=head1

=cut
