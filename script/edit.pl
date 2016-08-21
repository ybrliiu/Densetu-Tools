# 武将データ編集

use v5.14;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Encode qw/decode/;
binmode STDOUT, 'utf8';

use Densetu::Tools::UpdateTimeTable;

print "name:";
chomp(my $name = <STDIN>);
$name = decode('utf8', $name);
print "time(書式:xx分xx秒):";
chomp(my $time = <STDIN>);
$time = decode('utf8', $time);

Densetu::Tools::UpdateTimeTable->edit_player(
  name => $name,
  time => $time,
);

