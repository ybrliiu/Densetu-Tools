package Record::Base {

  use Record;
  use Record::Exception;
  use Carp qw/croak/;
  use Class::Accessor::Lite new => 0;
  use Storable qw/fd_retrieve nstore_fd nstore/;
  
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
      LOCK_SH => 1,    # 共有ロック
      LOCK_EX => 2,    # 排他ロック
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

  Class::Accessor::Lite->mk_accessors(qw/file fh/);

  # ファイルオープン
  sub open {
    my ($self, $lock_type) = @_;

    if ( $self->mode($lock_type) ) {
      open($self->{fh}, '+<', $self->{file}) or Record::Exception->throw("fileopen失敗:$!", $self);
      flock($self->{fh}, $self->mode($lock_type)) or Record::Exception->throw("flock失敗:$!", $self);
      $self->data(fd_retrieve $self->{fh});
    } else {
      open(my $fh, '<', $self->{file}) or Record::Exception->throw("fileopen失敗:$!", $self);
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
  sub close {
    my $self = shift;
    truncate($self->{fh}, 0)
      or Record::Exception->throw(
        '多分書き込みモードでファイルを開いていないか、書き込みモードで2度ファイルを開いています',
        $self,
      );
    seek($self->{fh}, 0, 0) or Record::Exception->throw('seek失敗', $self);
    nstore_fd($self->data, $self->{fh}) or Record::Exception->throw('nstore_fd失敗', $self);
    $self->data(undef);
    close($self->{fh}) or Record::Exception->throw('close失敗', $self);
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
