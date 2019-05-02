package Record::SystemErrorException {

  use Record;
  use Carp ();
  use parent 'Record::Exception';

  # override
  sub throw {
    my ($class, $msg, $errno) = @_;

    local $Carp::Internal{$class} = 1;

    return $class->SUPER::throw(
      message => $msg,
      errno   => $errno . '',
    );
  }

  # override
  sub as_string {
    my $self = shift;

    my $class = ref $self;
    my $template = << "EOS";
[${class}]

$self->{message} at $self->{file} line $self->{line}.
  $self->{call_sub} called at $self->{call_file} line $self->{call_line}.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Errorno:
  $self->{errno}
Trace:
  $self->{trace}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EOS
    return $template;
  }

}

1;
