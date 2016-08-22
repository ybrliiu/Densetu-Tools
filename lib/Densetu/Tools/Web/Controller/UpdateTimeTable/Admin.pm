package Densetu::Tools::Web::Controller::UpdateTimeTable::Admin {

  use Mojo::Base 'Mojolicious::Controller';
  use Densetu::Tools::UpdateTimeTable;

  sub root {
    my ($self) = @_;
    $self->render(msg => 'Welcome to densetu-tools!');
  }

  sub login {
    my ($self) = @_;

    my $json = $self->req->json();
    my ($pass, $check) = ($json->{pass}, $json->{check});
    my $admin_pass = $self->config->{app}{admin_password};

    {
      my $session = $self->session->{login};
      if ($session) {
        $self->render(text => 'success') if $json;
        return 1;
      }
    }

    if ($pass eq $admin_pass) {
      $self->session(login => 'login');
      if ($check) {
        $self->cookie(pass => $pass, {max_age => 1000000, path => '/update_time_table/admin_login_input'});
      }
      $self->render(text => 'success') if $json;
      return 1;
    }
    $self->render(text => 'パスワードが違います。') if $json;
    return 0;
  }

  sub logout {
    my ($self) = @_;
    $self->session(expires => 1);
    $self->redirect_to('/update_time_table');
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
