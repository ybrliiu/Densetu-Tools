package Mojolicious::Plugin::FTP {

  use Mojo::Base 'Mojolicious::Plugin';
  use Carp qw/croak/;
  use Net::FTP;

  sub register {
    my ($self, $app, $conf) = @_;

    $app->helper(ftp => sub {
      my ($c, %args) = @_;
      for (qw/host user password/) {
        croak "Please specify $_" unless defined $args{$_};
      }

      my $ftp = Net::FTP->new($args{host}, Debug => 0) || warn "connect failed.\n";
      $ftp->login($args{user}, $args{password}) || warn "login failed.\n", $ftp->message;
      $ftp;
    });
  }

}

1;
