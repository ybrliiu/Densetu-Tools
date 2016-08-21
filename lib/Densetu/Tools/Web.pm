package Densetu::Tools::Web {

  use Mojo::Base 'Mojolicious';

  sub startup {
    my ($self) = @_;

    # setup session
    $self->secrets(['densetu-tools']);
    $self->sessions->cookie_name('densetu-tools');
    $self->sessions->default_expiration(3600000);

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

    # player_info
    my $player_info = $r->any('/player_info')->to(controller => 'PlayerInfo');
    $player_info->get('/')->to(action => 'root');
    $player_info->post('/get_info')->to(action => 'get_info');

    # update_time_table
    my $update_time_table = $r->any('/update_time_table')->to(controller => 'UpdateTimeTable');
    $update_time_table->get('/')->to(action => 'root');
    $update_time_table->post('/get_table')->to(action => 'root');
    $update_time_table->post('/get_mix_table')->to(action => 'root');
    my $admin = $update_time_table->any('/admin')->to(controller => 'UpdateTimeTable::Admin');
    $admin->get('/')->to(action => 'root');
  }

}

1;
