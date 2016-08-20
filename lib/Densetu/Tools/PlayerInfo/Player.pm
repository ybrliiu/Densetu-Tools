package Densetu::Tools::PlayerInfo::Player {

  use v5.14;
  use warnings;
  use utf8;

  use Class::Accessor::Lite new => 0;

  {
    my %default = (
      type      => '',
      name      => '',
      status    => '',
      formation => '',
      soldier   => '',
      time      => '',
      skill     => [],
    );

    Class::Accessor::Lite->mk_accessors(keys %default);

    sub new {
      my ($class, %args) = @_;
      my $self = {%default, %args};
      return bless $self, $class;
    }
  }

  sub extract_attacker_name {
    my ($class, $log, $i) = @_;
    while (1) {
      $i--;
      if ($log->[$i] =~ /最大ダメージ：/) {
        my ($name) = ($log->[$i] =~ /【(.*?)の最大ダメージ：/);
        return $name;
      }
    }
  }

  sub extract_name_and_type {
    my ($class, $log, $i) = @_;
    my $line = $log->[$i];
    my ($name, $type) = do {
      if ($line =~ /戦闘しました！！/) {
        my ($name) = ($line =~ /へ攻め込み(.*?)（/);
        ($name, '守備側');
      } elsif ($line =~ /戦闘しました！/) {
        ($class->extract_attacker_name($log, $i), '攻撃側')
      } else {
        ()
      }
    };
    return ($name, $type);
  }

  sub extract_unique_key {
    my ($class, $log, $i) = @_;
    my ($name, $type) = $class->extract_name_and_type($log, $i);
    return $name ? "$name($type)" : ();
  }

  sub parse {
    my ($self, $log, $i) = @_;
    ($self->{name}, $self->{type}) = $self->extract_name_and_type($log, $i);
    $self->extract_time($log->[$i]);
    $self->extract_formation($log->[$i]);
    $self->extract_soldier($log, $i);
    $self->extract_status($log, $i);
  }

  sub extract_time {
    my ($self, $line) = @_;
    ($self->{time}) = ($line =~ /！(.*?)\)/);
    $self->{time} =~ s/！//;
    $self->{time} = $self->{time} . '）';
  }

  sub extract_formation {
    my ($self, $line) = @_;
    my $name = $self->{name};
    ($self->{formation}) = ($line =~ /$name（(.*?)）/);
    $self->{formation} = '(' . $self->{formation} . ')';
  }

  sub extract_soldier {
    my ($self, $log, $i) = @_;
    while (1) {
      $i--;
      if ($log->[$i] =~ /\|/ && $log->[$i] =~ /ターン/) {
        my $name = $self->{name} . ' ';
        ($self->{soldier}) = ($log->[$i] =~ /$name(.*?) /);
        last;
      }
    }
  }

  sub extract_status {
    my ($self, $log, $i) = @_;

    local $SIG{__WARN__} = sub {
      my ($warn_mes) = @_;
      say "warning!!";
      say "name: ", $self->{name};
    };

    while (1) {
      $i--;
      if ($log->[$i] =~ /（攻：守＝/) {
        my $name = $self->{name};
        ($self->{status}) = ($log->[$i] =~ /$name(.*?)】/);
        $self->{status} = '【' . $self->{name} . $self->{status} . '】';
        last;
      }
    }
  }

  sub unique_key {
    my ($self) = @_;
    return $self->{name} . '(' . $self->{type} . ')';
  }

  sub is_attack {
    my ($self) = @_;
    return $self->{type} eq '攻撃側';
  }

  sub output {
    my ($self) = @_;
    no warnings 'utf8';
    say "$self->{status} $self->{soldier}　$self->{formation}　$self->{time}";
  }

}

1;
