package Record::Exception {

  use parent 'Exception::Tiny';

  use Carp ();
  use Class::Accessor::Lite(
    new => 0,
    ro  => [qw/ call_package call_file call_line call_sub trace obj /],
  );

  sub throw {
    my $class = shift;

    my %args;
    if (@_ == 1) {
      $args{message} = shift;
    } else {
      %args = @_;
    }

    @args{qw/ package file line /} = caller(0);
    @args{qw/ call_package call_file call_line call_sub /} = caller(1);

    $args{trace} = $args{message} . Carp::longmess();

    die $class->new(%args);
  }

  sub as_string {
    my $self = shift;

    my $class = ref $self;
    my $template = << "EOS";
[${class}]

$self->{message} at $self->{file} line $self->{line}.
  $self->{call_sub} called at $self->{call_file} line $self->{call_line}.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Trace:
  $self->{trace}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EOS
    return $template;
  }

}

1;
