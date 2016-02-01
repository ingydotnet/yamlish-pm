use strict; use warnings;
use Test::More;

use lib '/home/ingy/src/pegex-pm/lib';
use YAMLish;
use JSON;

my $yaml;

is 'YAMLish'->load('[1,2,3]'), 'yay', 'Simple flow sequence';
# is 'YAMLish'->load('[1,2,3,]'), 'yay', 'Trailing newline in flow seq';
# is 'YAMLish'->load("[1,2,3]\n"), 'yay', 'Newline after flow seq';
# is 'YAMLish'->load("[a, b, 33]\n"), 'yay', 'Plain string in flow seq';
# is 'YAMLish'->load("{a: 42}\n"), 'yay', 'Simple flow mapping';
# is 'YAMLish'->load("{a: 42,}\n"), 'yay', 'Trailing comma in flow map';
# is 'YAMLish'->load("{a: 42, b: 43}\n"), 'yay', 'Flow map multiple pairs';
# is 'YAMLish'->load("{}\n"), 'yay', 'Empty flow map';
# is 'YAMLish'->load("foo\n"), 'yay', 'Plain scalar document';
$yaml = <<'...';
# YAML flow mapping
{
    # Map pair
    foo: 42,
}
# The End
...
# is 'YAMLish'->load($yaml), 'yay', 'YAML Comments';


done_testing;
