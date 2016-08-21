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
    $r->get('/')->to('root#root');

    # player-info
    $r->get('/player-info')->to('player_info#root');
    $r->any('/player-info/get_info')->to('player_info#get_info');
  }

}

1;
