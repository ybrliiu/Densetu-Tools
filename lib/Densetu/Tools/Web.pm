package Densetu::Tools::Web {

  use Mojo::Base 'Mojolicious';

  sub startup {
    my ($self) = @_;

    # setup session
    $self->secrets(['densetu-tools']);
    $self->sessions->cookie_name('densetu-tools');
    $self->sessions->default_expiration(3600000);

    # Router
    my $r = $self->routes;
    $r->namespaces([qw/Densetu::Tools::Web::Controller/]);

    # Normal route to controller
    $r->get('/')->to('Root#root');

    # player-info
    my $player_info = $r->any('/player_info')->to(controller => 'PlayerInfo');
    $player_info->get('/')->to(action => 'root');
    $player_info->any('/get_info')->to(action => 'get_info');
  }

}

1;
