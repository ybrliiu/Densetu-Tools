package Record::Base {

  use Record;
  use Record::Exception;
  use Record::SystemErrorException;
  use Carp qw/ croak /;
  use Storable qw/ fd_retrieve nstore_fd nstore /;

  use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/ file fh /],
  );
  
  sub data {
    my $self = shift;
    state $memory = {};
    $memory->{$self->{file}} = shift if @_;
    return $memory->{$self->{file}} ? $memory->{$self->{file}} : ();
  }

  # モード
  sub mode {
    my ($class, $key) = @_;
    $key //= '';
    state $mode = {
      LOCK_SH    => 1, # 共有ロック
      LOCK_EX    => 2, # 排他ロック
      NB_LOCK_SH => 5, # ノンブロックな共有ロック(ノンブロックの場合、ロックできなければdie）
      NB_LOCK_EX => 6, # ノンブロックな排他ロック
    };
    return exists $mode->{$key} ? $mode->{$key} : ();
  }

  sub new {
    my ($class, %args) = @_;
    croak 'fileを指定して下さい' unless exists $args{file};
    my $self = {file => "@{[ Record->project_dir ]}$args{file}"};
    return bless $self, $class;
  }

  # ファイルオープン
  sub open :method {
    my ($self, $lock_type) = @_;

    if ( $self->mode($lock_type) ) {

      unless ( open($self->{fh}, '+<', $self->{file}) ) {
        undef $self->{fh};
        Record::SystemErrorException->throw('fileopen失敗', $!);
      }

      unless ( flock($self->{fh}, $self->mode($lock_type)) ) {
        $self->{fh}->close();
        Record::SystemErrorException->throw('flock失敗', $!);
      }

      $self->data(fd_retrieve $self->{fh});
    } else {
      open(my $fh, '<', $self->{file})
        or Record::SystemErrorException->throw('fileopen失敗', $!);
      $self->data(fd_retrieve $fh);
      $fh->close;
    }

    return $self;
  }
  
  # ファイル作成
  sub make {
    my $self = shift;
    nstore($self->data, $self->file);
    return $self;
  }
  
  # ファイル閉じる
  sub close :method {
    my $self = shift;

    unless ( truncate($self->{fh}, 0) ) {
      $self->{fh}->close();
      Record::SystemErrorException->throw(
        'truncate失敗, おそらく書き込みモードでファイルを開いていないか、書き込みモードで2度ファイルを開いています',
        $!
      );
    }

    unless ( seek($self->{fh}, 0, 0) ) {
      $self->{fh}->close();
      Record::SystemErrorException->throw('seek失敗', $!);
    }

    unless ( nstore_fd($self->data, $self->{fh}) ) {
      $self->{fh}->close();
      Record::SystemErrorException->throw('nstore_fd失敗', $!);
    }

    $self->data(undef);
    close($self->{fh}) or Record::SystemErrorException->throw('close失敗', $!);
    $self->{fh} = undef;

    return 1;
  }
  
  # ファイル削除
  sub remove {
    my $self = shift;
    unlink $self->file;
  }

  sub DESTROY {
    my $self = shift;
    $self->close() if $self->fh;
  }
  
}

1;
