use strict; use warnings;
use Test::More;

use YAMLish;
use JSON;

is 'YAMLish'->load('...'), 'yay', 'Bogus starter test';

done_testing;
