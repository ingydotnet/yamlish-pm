use strict; use warnings;
package YAMLish;
use Pegex::Parser;


sub load {
    my ($class, $yaml) = @_;
    my $parser = Pegex::Parser->new(
        grammar => YAMLish::Grammar->new,
        receiver => YAMLish::Constructor->new,
    );
    return $parser->parse($yaml);
}

package YAMLish::Grammar;
use Pegex::Base;
extends 'Pegex::Grammar';

use constant text => <<'...';
yaml-stream: /\.\.\./
...

# This is the counterpart to a Perl 6 action class:
package YAMLish::Constructor;
use Pegex::Base;

sub got_yaml_stream {
    return 'yay';
}

1;
