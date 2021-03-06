package Densetu::Tools::ParseBattleLog::Player {

  use v5.14;
  use warnings;
  use utf8;
  use Class::Accessor::Lite new => 0;

  use Time::Piece;
  use Unicode::Japanese;

  {
    my %attributes = (
      type         => undef,
      name         => undef,
      status       => undef,
      status_notes => '',
      formation    => undef,
      soldier      => undef,
      time         => undef,
      time_obj     => undef,
      skill        => [],
    );

    Class::Accessor::Lite->mk_accessors(keys %attributes);

    sub new {
      my ($class, %args) = @_;
      my $self = {%attributes, %args};
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
    $self->extract_time_and_time_obj($log->[$i]);
    $self->extract_formation($log->[$i]);
    $self->extract_soldier($log, $i);
    $self->extract_status($log, $i);
    $self->extract_status_notes($log, $i);
  }

  sub extract_time_and_time_obj {
    my ($self, $line) = @_;
    ($self->{time}) = ($line =~ /！(.*?)\)/);
    $self->{time}   =~ s/！//;
    $self->{time}   = $self->{time} . ')';
    my $now  = localtime;
    my $time = Time::Piece->strptime("@{[ $now->year ]}年@{[ $now->mon ]}月@{[ $self->{time} ]}", "%Y年%m月(%d日%H時%M分)");
    $self->{time_obj} = $time;
  }

  sub extract_formation {
    my ($self, $line) = @_;
    my $name = $self->{name};
    ($self->{formation}) = ($line =~ /$name（(.*?)）/);
    $self->{formation} =~ s/の陣//;
  }

  sub extract_soldier {
    my ($self, $log, $i) = @_;
    while (1) {
      $i--;

      if ($log->[$i] =~ /\|/ && $log->[$i] =~ /ターン/) {
        my $name         = $self->{name} . ' ';
        (my $soldier)    = ($log->[$i] =~ /$name(.*?) /);
        (my $lank)       = ($soldier =~ /【(.*?)ランク】/);
        (my $type)       = ($soldier =~ /ランク】\((.*?)\)/);
        $self->{soldier} = "$lank$type";

        unless ($self->{soldier}) {
          ($self->{soldier} = $soldier) =~ s/隊//g;
          $self->{soldier} =~ s/\(無し\)//g;
        }

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

  sub extract_status_notes {
    my ($self, $log, $i) = @_;
    while ($log->[$i] !~ /の最大ダメージ：/) {
      $i--;
      my $line = $log->[$i];
      if ($line =~ /【万歳突撃】/) {
        (my $info) = ($line =~ /敵軍の攻撃力が(.*?)％アップ/);
        $info = Unicode::Japanese->new($info)->z2h->get();
        $self->{status_notes} .= "万歳+${info}%";
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
    return "$self->{status}$self->{status_notes}　$self->{soldier}　$self->{formation}　$self->{time}\n";
  }

  sub multi_byte {
    my ($str) = @_;
    my @multi = $str =~ m/\P{InBasicLatin}/g;
    return scalar(@multi);
  }

}

1;
