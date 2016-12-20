use v5.22;
use warnings;
use utf8;

use Data::Dumper;
use Path::Tiny;

my $test = path('town_data.txt')->slurp();
my @town_status = qw/name zei farmer farm business/;
my @town_data = split /\n/, $test;
@town_data = map {
   my $data = $_;
   my @data = (split /\t/, $data);
   +{ map {
     if ($town_status[$_] eq 'farm'
       || $town_status[$_] eq 'business'
     ) {
       $data[$_] = (split m!/!, $data[$_])[0];
     }
     $town_status[$_] => $data[$_]
   } 0 .. 4 };
} @town_data;

say Dumper \@town_data;

my $salary = 0;
for my $town (@town_data) {
  $salary += $town->{farm} * 12 * $town->{farmer} / 10000;
}

say "給料:$salary";
