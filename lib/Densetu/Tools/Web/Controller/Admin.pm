package Densetu::Tools::Web::Controller::Admin {

  use Mojo::Base 'Mojolicious::Controller';

  sub root {
    my ($self) = @_;
    $self->render(msg => 'Welcome to densetu-tools!');
  }

  sub login {
  }

  sub logout {
  }

  sub edit {
    my ($self) = @_;
  }

  sub edit_input {
    my ($self) = @_;
  }

  sub add {
    my ($self) = @_;
  }

  sub add_input {
    my ($self) = @_;
  }

  sub add_from_line {
    my ($self) = @_;
  }

  sub add_from_line_input {
    my ($self) = @_;
  }

  sub new_table {
    my ($self) = @_;
  }

}

1;
