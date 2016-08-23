# 更新時間から武将情報抽出

use v5.14;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Encode qw/decode/;
binmode STDOUT, 'utf8';

use Densetu::Tools::ParseBattleLog;

print "id:";
chomp(my $id = <STDIN>);
$id = decode('utf8', $id);
print "pass:";
chomp(my $pass = <STDIN>);
$pass = decode('utf8', $pass);

my $parse = Densetu::Tools::ParseBattleLog->new(
  id   => $id,
  pass => $pass,
);
say $parse->output;

=head1
use Encode 'decode';
my $log;
while (chomp(my $line = <STDIN>)) {
  last if $line eq '';
  $log .= "\n$line";
}
$log = decode('utf8', $log);
Densetu::Tools::ParseBattleLog->output($log);
=cut
