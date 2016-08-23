package Densetu::Tools::Web::Controller::ParseBattleLog {

  use Mojo::Base 'Mojolicious::Controller';
  use Densetu::Tools::ParseBattleLog;

  sub root {
    my ($self) = @_;
    $self->render();
  }

  sub get_info_input {
    my ($self) = @_;
    $self->render();
  }

  sub get_info {
    my ($self) = @_;

    my $json = $self->req->json;
    my ($id, $pass, $check) = ($json->{id}, $json->{pass}, $json->{check});

    if ($check) {
      my $url = $self->req->url->to_abs;
      $self->cookie(id => $id, {max_age => 10000000, path => $url});
      $self->cookie(pass => $pass, {max_age => 10000000, path => $url});
    }

    my $parse = Densetu::Tools::ParseBattleLog->new(
      id   => $id,
      pass => $pass,
    );
    my $result = $parse->output;

    $self->render(text => $result);
  }

  sub get_info_from_log_input {
    my ($self) = @_;
    $self->render();
  }

  sub get_info_from_log {
    my ($self) = @_;
  }

}

1;
