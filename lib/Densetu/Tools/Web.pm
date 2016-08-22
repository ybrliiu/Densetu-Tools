package Densetu::Tools::Web {

  use Mojo::Base 'Mojolicious';

  sub setup_session {
    my ($self) = @_;
    $self->plugin('Config', {file => 'etc/config/app.conf'});
    my $session = $self->config->{app}{session};
    $self->secrets([$session->{password}]);
    $self->sessions->cookie_name($session->{cookie_name});
    $self->sessions->default_expiration($session->{expiration});
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

    # Router
    my $r = $self->routes;
    $r->namespaces([qw/Densetu::Tools::Web::Controller/]);

    # Normal route to controller
    $r->get('/')->to('Root#root');

    # /player_info
    my $player_info = $r->any('/player_info')->to(controller => 'PlayerInfo');
    $player_info->get( '/'        )->to(action => 'root');
    $player_info->post('/get_info')->to(action => 'get_info');

    # /update_time_table
    my $update_time_table = $r->any('/update_time_table')->to(controller => 'UpdateTimeTable');
    $update_time_table->get( '/'                   )->to(action => 'root');
    $update_time_table->get( '/get_table_input'    )->to(action => 'get_table_input');
    $update_time_table->post('/get_table'          )->to(action => 'get_table');
    $update_time_table->get( '/get_mix_table_input')->to(action => 'get_mix_table_input');
    $update_time_table->post('/get_mix_table'      )->to(action => 'get_mix_table');
    $update_time_table->get( '/admin_login_input'  )->to(action => 'admin_login_input');

    # /update_time_table/admin
    my $admin = $update_time_table->any('/admin')->to(controller => 'UpdateTimeTable::Admin');
    $admin->post('/login'             )->to(action => 'login');
    $admin->post('/logout'             )->to(action => 'logout');
    my $auth = $admin->under->to(action => 'auth');
    $auth->get( '/'                   )->to(action => 'root');
    $auth->get( '/edit_input'         )->to(action => 'edit_input');
    $auth->post('/edit'               )->to(action => 'edit');
    $auth->get( '/add_input'          )->to(action => 'add_input');
    $auth->post('/add'                )->to(action => 'add');
    $auth->get( '/add_from_line_input')->to(action => 'add_from_line_input');
    $auth->post('/add_from_line'      )->to(action => 'add_from_line');
    $auth->post('/new_table'          )->to(action => 'new_table');
  }

}

1;
