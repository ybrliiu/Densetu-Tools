# 更新表リセット、新規作成

use v5.14;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Encode qw/decode/;
binmode STDOUT, 'utf8';

use Densetu::Tools::UpdateTimeTable;

Densetu::Tools::UpdateTimeTable->new_update_time_table();
