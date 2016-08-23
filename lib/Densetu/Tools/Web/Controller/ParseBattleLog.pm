package Densetu::Tools::Web::Controller::ParseBattleLog {

  use Mojo::Base 'Mojolicious::Controller';
  use Densetu::Tools::ParseBattleLog;

  sub root {
    my ($self) = @_;
    $self->render();
  }

  sub get_info {
    my ($self) = @_;

    my $json = $self->req->json;

    my $url = $self->req->url->to_abs;
    $self->cookie(id => $json->{id}, {max_age => 10000000, path => $url});
    $self->cookie(pass => $json->{pass}, {max_age => 10000000, path => $url});

    my $info = Densetu::Tools::ParseBattleLog->new(
      id   => $json->{id},
      pass => $json->{pass},
    );
    my $result = $info->output;

    $self->render(text => $result);
  }

}

1;
