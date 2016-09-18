#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, ("$FindBin::Bin/../lib", "$FindBin::Bin/../local/lib/perl5", "$FindBin::Bin/../local/lib/perl5/x86_64-linux") }
use Mojolicious::Commands;

# Start command line interface for application
Mojolicious::Commands->start_app('Densetu::Tools::Web');
