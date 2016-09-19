package Densetu::Tools::Web {

  use Mojo::Base 'Mojolicious';
  use Mojolicious::Plugin::FTP;

  sub setup_session {
    my ($self) = @_;
    $self->plugin('Config', {file => 'etc/config/app.conf'});
    my $session = $self->config->{app}{session};
    $self->secrets([$session->{password}]);
    $self->sessions->cookie_name($session->{cookie_name});
    $self->sessions->default_expiration($session->{expiration});
  }

  sub _ftp_session {
    my ($self, $code) = @_;
    my $ftp = $self->ftp(
      host     => $ENV{FTP_HOST},
      user     => $ENV{FTP_USER},
      password => $ENV{FTP_PASSWORD},
    );
    $ftp->cwd('www/');
    $code->($ftp);
    $ftp->quit();
  }
  
  sub _download_dat {
    my ($self) = @_;
    $self->_ftp_session(sub {
      my ($ftp) = @_;
      $ftp->get('player_map_log.dat', 'etc/record/player_map_log.dat') || warn 'get failed.', $ftp->message;
      warn "download success\n";
    });
  }
  

  sub startup {
    my ($self) = @_;

    $self->setup_session();

    # get cookie value from template. example:%= my_cookie('id');
    $self->helper(
      my_cookie => sub {
        my ($self, $name) = @_;
        $self->cookie($name);
      }
    );

    # load plugin
    # when you use Heroku, need to do this  process.
    # $self->plugin('FTP');
    # $self->_download_dat();

    # Router
    my $r = $self->routes;
    $r->namespaces([qw/Densetu::Tools::Web::Controller/]);

    # Normal route to controller
    $r->get('/')->to('Root#root');

    # /calc_slary
    $r->get('/calc_slary')->to('CalcSlary#root');

    # /parse_battle_log
    {
      my $parse_battle_log = $r->any('/parse_battle_log')->to(controller => 'ParseBattleLog');
      $parse_battle_log->get( '/'                       )->to(action => 'root');
      $parse_battle_log->get( '/get_info_input'         )->to(action => 'get_info_input');
      $parse_battle_log->post('/get_info'               )->to(action => 'get_info');
      $parse_battle_log->get( '/get_info_from_log_input')->to(action => 'get_info_from_log_input');
      $parse_battle_log->post('/get_info_from_log'      )->to(action => 'get_info_from_log');
    }

    # /update_time_table
    {
      my $update_time_table = $r->any('/update_time_table')->to(controller => 'UpdateTimeTable');
      $update_time_table->get( '/'                   )->to(action => 'root');
      $update_time_table->get( '/get_table_input'    )->to(action => 'get_table_input');
      $update_time_table->post('/get_table'          )->to(action => 'get_table');
      $update_time_table->get( '/get_mix_table_input')->to(action => 'get_mix_table_input');
      $update_time_table->post('/get_mix_table'      )->to(action => 'get_mix_table');
      $update_time_table->get( '/admin_login_input'  )->to(action => 'admin_login_input');

      # /update_time_table/admin
      {
        my $admin = $update_time_table->any('/admin')->to(controller => 'UpdateTimeTable::Admin');
        $admin->post('/login'             )->to(action => 'login');
        $admin->any( '/logout'            )->to(action => 'logout');
        my $auth = $admin->under->to(action => 'auth');
        $auth->get( '/'                   )->to(action => 'root');
        $auth->get( '/edit_input'         )->to(action => 'edit_input');
        $auth->post('/edit'               )->to(action => 'edit');
        $auth->get( '/add_input'          )->to(action => 'add_input');
        $auth->post('/add'                )->to(action => 'add');
        $auth->get( '/add_from_line_input')->to(action => 'add_from_line_input');
        $auth->post('/add_from_line'      )->to(action => 'add_from_line');
        $auth->get( '/new_table_input'    )->to(action => 'new_table_input');
        $auth->post('/new_table'          )->to(action => 'new_table');
        $auth->get( '/file_manager'       )->to(action => 'file_manager');
        $auth->post('/upload'             )->to(action => 'upload');
        $auth->post('/download'           )->to(action => 'download');
      }
    }

  }

  # when stop server
  # when you use heroku, need to do this process.
=head1
  sub DESTROY {
    my ($self) = @_;
    $self->_ftp_session(sub {
      my ($ftp) = @_;
      $ftp->put('etc/record/player_map_log.dat', 'player_map_log.dat') || warn 'put failed.', $ftp->message;
      warn "upload succes\n";
    });
  }
=cut

}

1;
