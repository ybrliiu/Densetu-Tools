package Densetu::Tools::PlayerInfo {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak confess/;
  use Class::Accessor::Lite new => 0;

  use Densetu::Tools::PlayerInfo::Player;
  use Encode qw/decode encode/;
  use LWP::UserAgent;

  sub new {
    my ($class, %args) = @_;
    for (qw/id pass/) {
      confess $_ . 'が指定されていません' unless exists $args{$_};
    }
    return bless \%args, $class;
  }

  Class::Accessor::Lite->mk_accessors(qw/id pass/);

  sub output {
    my ($self) = @_;

    my $output = $self->get_log();
    my $players = $self->extraction($output);

    no warnings 'utf8';
    say "\n----------------------------------\n";
    say 'こちら攻め';
    for my $player (values %$players) {
      $player->output unless $player->is_attack;
    }

    say "\n相手攻め";
    for my $player (values %$players) {
      $player->output if $player->is_attack;
    }
  }

  sub get_log {
    my ($self) = @_;
    no warnings 'utf8';

    my $ua = LWP::UserAgent->new();
    $ua->timeout(60);
    say '取得中...';
    my $response = $ua->get("http://densetu.sakura.ne.jp/mydata3.cgi?id=@{[ $self->{id} ]}&pass=@{[ $self->{pass} ]}=doodoo5&mode=STATUS");
    if ($response->is_success) {
      say '完了';
      return decode('shift-jis', $response->content);
    } else {
      croak 'ログ情報の取得に失敗、', $response->status_line;
    }
  }

  sub extraction {
    my ($self, $get_log) = @_;

    my %players;
    my @log = grep { $_ =~ /●/ } (split /\n/, $get_log);
    for my $i (0 .. @log-1) {
      my $key = 'Densetu::Tools::PlayerInfo::Player'->extract_unique_key(\@log, $i);
      if ($key) {
        next if exists $players{$key};
        my $player = 'Densetu::Tools::PlayerInfo::Player'->new();
        $player->parse(\@log, $i);
        $players{$key} = $player;
      }
    }

    return \%players;
  }

}

1;
