package Record::Hash {
  
  use parent 'Record::Base';
  use Record;
  use Record::Exception;
  
  # データ取得
  sub find {
    my ($self, $key) = @_;
    my $data = $self->data;
    return exists($data->{$key})
      ? $data->{$key}
      : Record::Exception->throw("キーが存在しません (key : $key)");
  }

  # キーに対応するデータの存在確認
  sub exists {
    my ($self, $key) = @_;
    my $data = $self->data;
    return exists($data->{$key});
  }

  # 格納されているオブジェクト内、$nameアテリビュートと$valueが対応するオブジェクトのリストを返却(DBのSELECT文的な)
  sub search {
    my ($self, $name, $value) = @_;
    return map { $_->$name eq $value ? $_ : () } values %{ $self->data };
  }

  sub each {
    my ($self, $code) = @_;
    my %data = %{ $self->data };
    for (keys %data) {
      $code->($_, $data{$_});
    }
  }

  sub map {
    my ($self, $code) = @_;
    my $hash = $self->data;
    my @result;
    push @result, $code->($_, $hash->{$_}) for keys %$hash;
    return @result;
  }
  
  # データ追加
  sub add {
    my ($self, $key, $obj) = @_;
    my $data = $self->data;
    Record::Exception->throw('空文字列をキーとして使用することはできません') if $key eq '';
    Record::Exception->throw("既に同じキーのデータがあります (key : $key)") if exists $data->{$key};
    $data->{$key} = $obj;
    $self->data($data);
    return $self;
  }
  
  # データ更新
  sub update {
    my ($self, $key, $obj) = @_;
    $self->find($key);
    my $data = $self->data;
    $data->{$key} = $obj;
    $self->data($data);
    return $self;
  }
  
  # データ削除
  sub delete {
    my ($self, $key) = @_;
    $self->find($key);
    my $data = $self->data;
    delete $data->{$key};
    $self->data($data);
    return $self;
  }
  
  # キーの一覧を取得
  sub get_list {
    my $self = shift;
    my @list = keys %{ $self->data };
    return \@list;
  }
  
}

1;
