package Densetu::Tools::UpdateTimeTable::Player {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak/;
  use Class::Accessor::Lite new => 0;

  use Time::Piece;

  {
    my %attributes = (
      name        => undef,
      time        => '????',
      time_origin => undef,
      country     => undef,
      force       => 0,
      intellect   => 0,
      leadership  => 0,
      popular     => 0,
      line        => undef,
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
    $self->{line} = $line;
    ($self->{name}, $self->{country}, $self->{time}) = do {
      if ($line =~ /【建国】/) {
        ($line =~ /新しく(.*?)率いる(.*?)が蜂起しました。\((.*?)\)/);
      }
      elsif ($line =~ /\[仕官\]/) {
        ($line =~ /新しく(.*?)が(.*?)に仕官しました。\((.*?)\)/);
      }
      elsif ($line =~ /へ攻め込みました！/) {
        my ($country, $name, $target_town, $target_country, $time)
          = ($line =~ /・(.*?)の(.*)は(.*?)（(.*?)）へ攻め込みました！\((.*?)\)/);
        my ($position) = $name =~ /【(.*?)】/;
        $position //= '';
        $name =~ s/【${position}】//;
        ($name, $country, $time);
      }
      else {
        croak "文字列に武将情報が含まれていません";
      }
    };
    $self->time_str_convert_obj;
  }

  # 国名, プレイヤー名に「の」がたくさん含まれていた場合
  # 引数に国名も与えて、確実に判定させる
  sub reparse {
    my ($self, $country_name) = @_;
    ($self->{name}, $self->{country}, $self->{time}) = do {
      croak "reparseできない文字列です ($self->{line})" if $self->{line} !~ /へ攻め込みました！/;
      $self->{line} =~ s/$country_name//;
      my ($name, $target_town, $target_country, $time)
        = ($self->{line} =~ /・の(.*)は(.*?)（(.*?)）へ攻め込みました！\((.*?)\) /);
      my ($position) = $name =~ /【(.*?)】/;
      $position //= '';
      $name =~ s/【${position}】//;
      ($name, $country_name, $time);
    };
    $self->time_str_convert_obj;
  }

  sub time_str_convert_obj {
    my ($self) = @_;
    my $now = localtime;
    my $time = eval {
      Time::Piece->strptime("@{[ $now->year ]}年@{[ $now->mon ]}月$self->{time}", "%Y年%m月%d日%H時%M分%S秒");
    };
    $self->{time} = $@ ? '????' : $time;
  }

  sub input_time {
    my ($self, $str) = @_;
    my $now = localtime;
    my $time = Time::Piece->strptime("@{[ $now->year ]}年@{[ $now->mon ]}月@{[ $now->mday ]}日@{[ $now->hour ]}時$str", "%Y年%m月%d日%H時%M分%S秒");
    $self->{time} = $time;
  }

  sub min_sec {
    my ($self) = @_;
    _min_sec( $self->{time} );
  }

  # origin 
  sub origin_min_sec {
    my ($self) = @_;
    _min_sec( $self->{time_origin} );
  }

  # あとでtest
  sub _min_sec {
    my ($time) = @_;
    my ($hour, $sec) = eval {
      $time->strftime("%M"),
      $time->strftime("%S")
    };
    return $@ ? 3600 : $hour * 60 + $sec;
  }

  sub update_time {
    my ($self, $new_time) = @_;
    $self->{time_origin} = $self->{time};
    warn " $self->{name} no time origin id $self->{time_origin} ";
    $self->{time}        = $new_time;
    warn " $self->{name} no time origin id $self->{time_origin} ";
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
      if ( $self->is_largest_ability('force') ) {
        '[武]'
      } elsif ( $self->is_largest_ability('intellect') ) {
        '[文]'
      } elsif ( $self->is_largest_ability('leadership') ) {
        '[統]'
      } elsif ( $self->is_largest_ability('popular') ) {
        '[人]'
      } else {
        '[均]'
      }
    };
    return $type;
  }

  sub is_largest_ability {
    my ($self, $ability) = @_;
    state $abilities = [qw/force intellect leadership popular/];
    my $count = 0;
    for (@$abilities) {
      if ($_ ne $ability) {
        $count++ if $self->{$ability} > $self->{$_};
      }
    }
    return $count == 3;
  }

  sub update_time_table {
    my ($self) = @_;
    return "@{[ $self->{mark} ]} @{[ $self->show_time ]}　@{[ $self->type ]}　@{[ $self->name ]}\n";
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
