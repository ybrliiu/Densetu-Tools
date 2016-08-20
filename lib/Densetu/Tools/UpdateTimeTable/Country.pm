package Densetu::Tools::UpdateTimeTable::Country {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak confess/;
  use Class::Accessor::Lite new => 0;

  use LWP::UserAgent;
  use HTML::TreeBuilder;
  use Encode qw/decode encode/;
  use Record::Hash;
  use Densetu::Tools::UpdateTimeTable::Player;

  Class::Accessor::Lite->mk_accessors(qw/name no/);

  sub new {
    my ($class, $line) = @_;
    my $self = bless {}, $class;
    $self->{name} = $self->extract_name($line);
    $self->{no} = $self->extract_no($line);
    return $self;
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
    my ($self, $line) = @_;
    return "http://densetu.sakura.ne.jp/ranking.cgi?mode=C_RAN&con_no=@{[ $self->{no} ]}";
  }

  sub get_member_info {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new();
    $ua->timeout(60);
    say '情報取得中...';
    my $response = $ua->get($self->member_url);

    if ($response->is_success) {
      say '完了';
      return decode('shift-jis', $response->content);
    } else {
      die 'ログ情報の取得に失敗、', $response->status_line;
    }
  }

  sub extract_member_line {
    my ($self) = @_;
    my $member_info = $self->get_member_info;
    my @lines = split /\n/, $member_info;
    my ($member_line) = grep $_ =~ /<TH>名前<\/TH><TH>武力<\/TH><TH>知力<\/TH>/, @lines;
    return $member_line;
  }

  sub create_member_info {
    my ($self) = @_;

    my $member_line = $self->extract_member_line;
    my $html = HTML::TreeBuilder->new();
    my $root = $html->parse($member_line);
    my @tr = $root->find('tr');
    shift @tr;

    my $record = Record::Hash->new(File => 'player_map_log.dat');
    my %players = %{ $record->open('LOCK_EX')->Data };

    for my $tag (@tr) {

      my @player_info = map {
        my ($link) = $_->find('a');
        $link ? $link->as_text : $_->as_text;
      } $tag->find('td');
      shift @player_info;

      my $player_name = $player_info[0];
      my $player;
      if (exists $players{$player_name}) {
        $player = $players{$player_name};
        $player->country($self->{name}) if $player->country ne $self->{name};
      } else {
        say "不明な武将データが発見されました($player_name)。新規武将データを作成します。";
        $player = 'Densetu::Tools::UpdateTimeTable::Player'->new(
          name    => $player_name,
          country => $self->{name},
          time    => '????',
        );
        $player->name($player_name);
        $record->Data->{$player_name} = $player;
      }

      $player->set_country_member_info(@player_info);
    }

    $record->close();
  }

}

1;
