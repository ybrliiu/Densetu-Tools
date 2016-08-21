# 更新表出力

use v5.14;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Encode qw/decode/;
binmode STDOUT, 'utf8';

use Densetu::Tools::UpdateTimeTable;

print "国名1:";
chomp(my $country1 = <STDIN>);
$country1 = decode('utf8', $country1);
print "国名2:";
chomp(my $country2 = <STDIN>);
$country2 = decode('utf8', $country2);

say Densetu::Tools::UpdateTimeTable->output_mix_table(
  country1 => $country1,
  country2 => $country2,
);
