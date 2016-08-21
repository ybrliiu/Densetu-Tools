package Record::Base {

  use Record;
  use Carp qw/croak confess/; # モジュールでのdie;
  use Class::Accessor::Lite new => 0;
  use Storable qw/fd_retrieve nstore_fd nstore/; # データ保存用
  
  sub Data {
    my $self = shift;
    state $memory = {};
    $memory->{$self->{File}} = shift if @_;
    return $memory->{$self->{File}} ? $memory->{$self->{File}} : ();
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
    croak 'Fileを指定して下さい' unless exists $args{File};
    my $self = {File => "@{[ Record->project_dir ]}$args{File}"};
    return bless $self, $class;
  }

  Class::Accessor::Lite->mk_accessors(qw/File FH/);

  # ファイルオープン
  sub open {
    my ($self, $lock_type) = @_;

    if ( $self->mode($lock_type) ) {
      open($self->{FH}, '+<', $self->{File}) or confess "fileopen失敗:$!" . $self->{File};
      flock($self->{FH}, $self->mode($lock_type)) or confess "flock失敗:$!";
      $self->Data(fd_retrieve $self->{FH});
    } else {
      open(my $fh, '<', $self->{File}) or confess "fileopen失敗:$!" . $self->{File};
      $self->Data(fd_retrieve $fh);
      $fh->close;
    }

    return $self; # メソッドチェーン用
  }
  
  # ファイル作成
  sub make {
    my $self = shift;
    nstore($self->Data, $self->File);
    return $self; # メソッドチェーン用
  }
  
  # ファイル閉じる
  sub close {
    my $self = shift;
    truncate($self->{FH}, 0) or confess '多分書き込みモードでファイルを開いていないか、書き込みモードで2度ファイルを開いています';
    seek($self->{FH}, 0, 0) or confess 'seek失敗';
    nstore_fd($self->Data, $self->{FH}) or confess 'nstore_fd失敗';
    $self->Data(undef);
    close($self->{FH}) or confess 'close失敗';
    return 1;
  }
  
  # ファイル削除
  sub remove {
    my $self = shift;
    unlink $self->File;
  }
  
}

1;
