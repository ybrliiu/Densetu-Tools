package Densetu::Tools::Web::Controller::UpdateTimeTable::Admin {

  use Mojo::Base 'Mojolicious::Controller';
  use Densetu::Tools::UpdateTimeTable;

  my $TOOL_CLASS = 'Densetu::Tools::UpdateTimeTable';

  sub root {
    my ($self) = @_;
    $self->render(msg => 'Welcome to densetu-tools!');
  }

  sub login {
    my ($self) = @_;

    my $json = $self->req->json();
    my ($pass, $check) = ($json->{pass}, $json->{check});
    my $admin_pass = $self->config->{app}{admin_password};

    if ($pass eq $admin_pass) {
      $self->session(login => 'login');
      if ($check) {
        $self->cookie(pass => $pass, {max_age => 1000000, path => '/update_time_table/admin_login_input'});
      }
      $self->render(text => 'success');
    } else {
      $self->session(expires => 1);
      $self->render(text => 'パスワードが違います。');
    }
  }

  sub logout {
    my ($self) = @_;
    $self->session(expires => 1);
    $self->redirect_to('/update_time_table');
  }

  sub auth {
    my ($self) = @_;
    my $session = $self->session->{login};
    return 1 if $session;
    $self->redirect_to('/update_time_table');
    return 0;
  }

  sub edit {
    my ($self) = @_;

    my $json = $self->req->json();
    use Data::Dumper;
    say Dumper $json;

    $self->render(text => 'hey/');
  }

  sub edit_input {
    my ($self) = @_;
    $self->render();
  }

  sub add {
    my ($self) = @_;
  }

  sub add_input {
    my ($self) = @_;
    $self->render();
  }

  sub add_from_line {
    my ($self) = @_;

    my $json = $self->req->json();
    my @lines = @{ $self->_parse_line_data($json->{line_data}) };
    say $_ for @lines;
    # Densetu::Tools::UpdateTimeTable->add_player_from_line($line);

    $self->render(text => '成功しました。');
  }

  sub _parse_line_data {
    my ($self, $text) = @_;
    my @lines = split /\n/, $text;
    return \@lines;
  }

  sub add_from_line_input {
    my ($self) = @_;
    $self->render();
  }

  sub new_table {
    my ($self) = @_;
    $self->render();
  }

  sub new_table_input {
    my ($self) = @_;
  }

}

1;
