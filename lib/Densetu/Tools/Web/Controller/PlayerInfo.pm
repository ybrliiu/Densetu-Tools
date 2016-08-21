package Densetu::Tools::Web::Controller::PlayerInfo {

  use Mojo::Base 'Mojolicious::Controller';

  sub root {
    my ($self) = @_;
    $self->render();
  }

  sub get_info {
    my ($self) = @_;

    my $json = $self->req->json;
    my $info = "result: $json->{id} + $json->{pass}";

    $self->render(text => $info);
  }

}

1;
