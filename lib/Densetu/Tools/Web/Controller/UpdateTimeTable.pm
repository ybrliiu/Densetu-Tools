package Densetu::Tools::Web::Controller::UpdateTimeTable {

  use Mojo::Base 'Mojolicious::Controller';
  use Densetu::Tools::UpdateTimeTable;

  sub root {
    my ($self) = @_;
    $self->render;
  }

  sub get_table_input {
    my ($self) = @_;
    my $countries = Densetu::Tools::UpdateTimeTable->create_country_list;
    $self->stash(countries => $countries);
    $self->render;
  }

  sub get_table {
    my ($self) = @_;

    my $json = $self->req->json;
    my $table = eval {
      Densetu::Tools::UpdateTimeTable->output_table(country => $json->{country});
    };
    if (my $e = $@) {
      return $self->render(text => $e);
    }

    $self->render(text => $table);
  }

  sub get_mix_table_input {
    my ($self) = @_;
    my $countries = Densetu::Tools::UpdateTimeTable->create_country_list;
    $self->stash(countries => $countries);
    $self->render;
  }

  sub get_mix_table {
    my ($self) = @_;

    my $json = $self->req->json;
    my $table = eval {
      Densetu::Tools::UpdateTimeTable->output_mix_table(
        country1 => $json->{country1},
        country2 => $json->{country2},
      );
    };
    if (my $e = $@) {
      return $self->render(text => $e);
    }

    $self->render(text => $table);
  }

  sub admin_login_input {
    my ($self) = @_;
    $self->render();
  }

}

1;
