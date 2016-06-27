package Densetu::Tools::UpdateTimeTable::Player {

  use v5.18;
  use warnings;
  use utf8;
  use Carp qw/croak/;
  use Class::Accessor::Lite new => 0;

  use Time::Piece;

  my @ATTRIBUTE = qw/name time country force intellect leadership popular/;
  Class::Accessor::Lite->mk_accessors(@ATTRIBUTE);

  sub new {
    my ($class, $line) = @_;
    my $self = bless {}, $class;
    $self->{name} = $self->extract_name($line);
    $self->{time} = $self->extract_time($line);
    $self->{country} = $self->extract_country($line);
    $self->{force} = 0;
    $self->{intellect} = 0;
    $self->{leadership} = 0;
    $self->{popular} = 0;
    return $self;
  }

  sub extract_name {
    my ($self, $line) = @_;
    my ($name) = do {
      if ($line =~ /【建国】/) {
        ($line =~ /新しく(.*?)率いる/);
      } elsif ($line =~ /\[仕官\]/) {
        ($line =~ /新しく(.*?)が/);
      } else {
        croak "名前の情報が含まれていません";
      }
    };
    return $name;
  }

  sub extract_time {
    my ($self, $line) = @_;
    my $now = localtime;
    my ($time_str) = ($line =~ /。\((.*?)\)/);
    my $time;
    eval { $time = Time::Piece->strptime("@{[ $now->year ]}年@{[ $now->mon ]}月$time_str", "%Y年%m月%d日%H時%M分%S秒") };
    return $@ ? '????' : $time;
  }

  sub input_time {
    my ($self, $str) = @_;
    my $now = localtime;
    my $time = Time::Piece->strptime("@{[ $now->year ]}年@{[ $now->mon ]}月@{[ $now->mday ]}日@{[ $now->hour ]}時$str", "%Y年%m月%d日%H時%M分%S秒");
    $self->{time} = $time;
  }

  sub extract_country {
    my ($self, $line) = @_;
    my ($country) = do {
      if ($line =~ /【建国】/) {
        ($line =~ /率いる(.*?)が蜂起しました。/)
      } elsif ($line =~ /\[仕官\]/) {
        ($line =~ /が(.*?)に仕官しました。/)
      } else {
        ()
      }
    };
    return $country;
  }

  sub hour_sec {
    my ($self) = @_;
    my ($hour, $sec);
    eval {
      $hour = $self->{time}->strftime("%M");
      $sec = $self->{time}->strftime("%S");
    };
    return $@ ? 9999 : ($hour * 100) + $sec;
  }

  sub show_time {
    my ($self) = @_;
    my $return;
    eval { $return = $self->{time}->strftime("%M:%S") };
    return $@ ? '??:??' : $return;
  }

  sub set_country_member_info {
    my ($self, $name, $force, $intellect, $leadership, $popular) = @_;
    $self->{force} = $force;
    $self->{intellect} = $intellect;
    $self->{leadership} = $leadership;
    $self->{popular} = $popular;
  }

  sub type {
    my ($self) = @_;
    my $type = do {
      if ($self->{force} > $self->{intellect} && $self->{force} > $self->{leadership} && $self->{force} > $self->{popular}) {
        '[武]'
      } elsif ($self->{intellect} > $self->{force} && $self->{intellect} > $self->{leadership} && $self->{intellect} > $self->{popular}) {
        '[文]'
      } elsif ($self->{leadership} > $self->{force} && $self->{leadership} > $self->{intellect} && $self->{leadership} > $self->{popular}) {
        '[統]'
      } elsif ($self->{popular} > $self->{force} && $self->{popular} > $self->{leadership} && $self->{popular} > $self->{intellect}) {
        '[人]'
      } else {
        '[均]'
      }
    };
    return $type;
  }

  sub update_time_table {
    my ($self) = @_;
    return "@{[ $self->{mark} ]} @{[ $self->show_time ]}　@{[ $self->type ]}　@{[ $self->name ]}";
  }

  sub mark {
    my $self = shift;
    if (@_) {
      $self->{mark} = shift;
      return $self;
    }
    return $self->{mark};
  }

}

1;

__END__

=encoding utf-8

=head1 更新表用プレイヤーオブジェクト

=cut
