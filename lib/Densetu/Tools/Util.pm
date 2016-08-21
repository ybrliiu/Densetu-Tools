package Densetu::Tools::Util {

  use v5.14;
  use warnings;
  use utf8;
  use Carp qw/croak/;

  use Exporter 'import';
  our @EXPORT_OK = qw/get_data/;

  use LWP::UserAgent;
  use Encode qw/decode/;

  sub get_data {
    my ($url) = @_;

    my $ua = LWP::UserAgent->new();
    $ua->timeout(60);

    say '情報取得中...';
    my $response = $ua->get($url);

    if ($response->is_success) {
      say '完了';
      return decode('shift-jis', $response->content);
    } else {
      croak 'ログ情報の取得に失敗、', $response->status_line;
    }
  }

}

1;
