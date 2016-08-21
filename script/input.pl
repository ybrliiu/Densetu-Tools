# キャラ情報編集用

use v5.14;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Encode qw/decode/;
binmode STDOUT, 'utf8';

use Densetu::Tools::UpdateTimeTable;

print "行を入力してください:";
chomp(my $line = <STDIN>);
$line = decode('utf-8', $line);
Densetu::Tools::UpdateTimeTable->add_player($line);

