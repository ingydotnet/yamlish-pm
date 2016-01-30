use strict; use warnings;
use Test::More;

use lib '/home/ingy/src/pegex-pm/lib';
use YAMLish;
use JSON;

is 'YAMLish'->load('[1,2,3]'), 'yay', 'Bogus starter test';

done_testing;
