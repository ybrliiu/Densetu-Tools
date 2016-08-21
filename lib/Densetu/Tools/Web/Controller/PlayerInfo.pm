package Densetu::Tools::Web::Controller::PlayerInfo {

  use Mojo::Base 'Mojolicious::Controller';
  use Densetu::Tools::PlayerInfo;

  sub root {
    my ($self) = @_;
    $self->render();
  }

  sub get_info {
    my ($self) = @_;

    my $json = $self->req->json;
    my $info = Densetu::Tools::PlayerInfo->new(
      id   => $json->{id},
      pass => $json->{pass},
    );
    my $result = $info->output;

    $self->render(text => $result);
  }

}

1;
