package Densetu::Tools::ParseBattleLog {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak/;
  use Class::Accessor::Lite new => 0;

  use Densetu::Tools::Util qw/get_data/;
  use Densetu::Tools::ParseBattleLog::Player;

  {
    my @attributes = qw/id pass/;

    Class::Accessor::Lite->mk_accessors(@attributes);

    sub new {
      my ($class, %args) = @_;
      for (@attributes) {
        croak $_ . 'が指定されていません' unless exists $args{$_};
      }
      return bless \%args, $class;
    }
  }

  sub output {
    my $self = shift;

    my $output = do {
      if (ref $self) {
        $self->get_log()
      } else {
        my $log = shift;
        $log;
      }
    };
    croak 'ログの取得に失敗しました' unless defined $output;

    my $players      = $self->extraction($output);
    my @sort_players = sort { $b->time_obj <=> $a->time_obj } values %$players;

    say "\n----------------------------------\n";

    my $result;
    $result .= "こちら攻め\n";
    for my $player (@sort_players) {
      $result .= $player->output unless $player->is_attack;
    }

    $result .= "\n相手攻め\n";
    for my $player (@sort_players) {
      $result .= $player->output if $player->is_attack;
    }

    return $result;
  }

  sub get_log {
    my ($self) = @_;
    get_data("http://densetu.sakura.ne.jp/mydata3.cgi?id=@{[ $self->{id} ]}&pass=@{[ $self->{pass} ]}=doodoo5&mode=STATUS");
  }

  sub extraction {
    my ($self, $get_log) = @_;

    my %players;
    my @log = grep { $_ =~ /●/ } (split /\n/, $get_log);
    for my $i (0 .. @log-1) {
      my $key = 'Densetu::Tools::ParseBattleLog::Player'->extract_unique_key(\@log, $i);
      if ($key) {
        next if exists $players{$key};
        my $player = 'Densetu::Tools::ParseBattleLog::Player'->new();
        $player->parse(\@log, $i);
        $players{$key} = $player;
      }
    }

    return \%players;
  }

}

1;

=encoding utf8

=head1 NAME

Densetu::Tools::ParseBattleLog - ログから武将情報を抽出して表示するツール

=head1 SYNOPSIS

  use Densetu::Tools::ParseBattleLog;

  # IDとPASSだけ指定するやり方
  my $info = Densetu::Tools::ParseBattleLog->new(
    id => 'player_id',
    pass => 'player_pass',
  );
  $info->output;

  # ログだけ渡して抽出
  my $log;
  while (chomp(my $line = <STDIN>)) {
    last if $line eq '';
    $log .= "\n$line";
  }
  Densetu::Tools::ParseBattleLog->output($log);

=head1 ATTRIBUTES

=head2 id

抽出するログのプレイヤーID

=head2 pass

抽出するログのプレイヤーPASS

=head1 METHODS

=head2 output

  $info->output;
  # or
  Densetu::Tools::ParseBattleLog->output($log);

ログを分析し、ログに含まれる武将情報をまとめて表示します。
クラスメソッドとしても動作します。その場合はログ自体の情報をこのメソッドに渡す必要があります。

=cut
