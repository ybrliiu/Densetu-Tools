package Densetu::Tools::Web::Controller::Root {

  use Mojo::Base 'Mojolicious::Controller';

  sub root {
    my ($self) = @_;
    $self->render(msg => 'Welcome to densetu-tools!');
  }

}

1;
