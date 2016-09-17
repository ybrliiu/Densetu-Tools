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
        $self->cookie(admin_password => $pass, {max_age => 1000000, path => '/update_time_table/admin_login_input'});
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
    my @parse_lines = @{ $self->_parse_player_data($json->{player_data}) };

    eval {
      $TOOL_CLASS->edit_player(%$_) for @parse_lines;
    };

    if (my $e = $@) {
      $self->render(text => $e);
    } else {
      $self->render(text => '編集完了しました。');
    }
  }

  sub edit_input {
    my ($self) = @_;
    $self->render();
  }

  sub add {
    my ($self) = @_;

    my $json = $self->req->json();
    my @parse_lines = @{ $self->_parse_player_data($json->{player_data}) };

    eval {
      $TOOL_CLASS->add_player(%$_) for @parse_lines;
    };

    if (my $e = $@) {
      $self->render(text => $e);
    } else {
      $self->render(text => '追加完了しました。');
    }
  }

  sub add_input {
    my ($self) = @_;
    $self->render();
  }

  sub _parse_player_data {
    my ($self, $text) = @_;
    my @lines = split /\n/, $text;
    my @parse_lines = map {
      my @player_data = split /,/, $_;
      @player_data = @{ $self->_fix_unusual_player_data(\@player_data) } if @player_data > 2;
      +{
        name => $player_data[0],
        time => $player_data[1],
      };
    } @lines;
    return \@parse_lines;
  }

  sub _fix_unusual_player_data {
    my ($self, $player_data) = @_;
    my $time = pop @$player_data;
    my $name;
    $name .= $_ for @$player_data;
    my @fix_data = ($name, $time);
    return \@fix_data;
  }

  sub add_from_line {
    my ($self) = @_;

    my $json = $self->req->json();
    my @lines = @{ $self->_parse_line_data($json->{line_data}) };
    warn $_ for @lines;

    eval {
      $TOOL_CLASS->add_player_from_line($_) for @lines;
    };

    if (my $e = $@) {
      $self->render(text => $e);
    } else {
      $self->render(text => '武将情報追加完了しました。');
    }
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

    eval {
      $TOOL_CLASS->new_update_time_table();
    };

    if (my $e = $@) {
      $self->render(text => $e);
    } else {
      $self->render(text => '操作完了しました。');
    }
  }

  sub new_table_input {
    my ($self) = @_;
    $self->render();
  }

  sub file_manager {
    my ($self) = @_;
    $self->render();
  }

  sub _ftp_session {
    my ($self, $code) = @_;
    my $ftp = $self->ftp(
      host     => $ENV{FTP_HOST},
      user     => $ENV{FTP_USER},
      password => $ENV{FTP_PASSWORD},
    );
    $ftp->cwd('/www') || die 'Cannot change working directory', $self->message;
    $code->($ftp);
    $ftp->quit();
  }
  
  sub download {
    my ($self) = @_;

    eval {
      $self->_ftp_session(sub {
        my ($ftp) = @_;
        $ftp->get('player_map_log.dat', 'etc/record/player_map_log.dat') || die 'download failed.', $ftp->message;
      });
    };

    if (my $e = $@) {
      $self->render(text => $e);
    } else {
      $self->render(text => 'downloadに成功しました.');
    }

  }

  sub upload {
    my ($self) = @_;

    eval {
      $self->_ftp_session(sub {
        my ($ftp) = @_;
        $ftp->put('etc/record/player_map_log.dat', 'player_map_log.dat') || die 'put failed.', $ftp->message;
      });
    };

    if (my $e = $@) {
      $self->render(text => $e);
    } else {
      $self->render(text => 'uploadに成功しました.');
    }

  }

}

1;
