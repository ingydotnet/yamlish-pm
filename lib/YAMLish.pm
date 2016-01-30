use strict; use warnings;
package YAMLish;
use Pegex::Parser;
use XXX;

sub load {
    my ($class, $yaml) = @_;
    my $parser = Pegex::Parser->new(
        grammar => YAMLish::Grammar->new,
        receiver => YAMLish::Constructor->new,
        # debug => 1,
    );
    # XXX $parser->grammar->tree;
    return $parser->parse($yaml);
}

package YAMLish::Grammar;
use Pegex::Base;
extends 'Pegex::Grammar';

use constant text => <<'...';
%grammar yamlish
%version 0.0.1

#   token TOP {
#     <.document-prefix>?
#     [
#     | <document=directive-document>
#     | <document=explicit-document>
#     | <document=simple-document>
#     ]
#     [
#     | <.document-suffix>+ <.document-prefix>* <document=any-document>?
#     | <.document-prefix>* <document=explicit-document>
#     ]*
#   }
yaml-stream:
    document-prefix?
    (
    | directive-document
    | explicit-document
    | simple-document
    )
#     (
#     | document-suffix+ document-prefix* any-document?
#     | document-prefix* explicit-document
#     )*
#   token document-prefix {
#     <.bom>? <.comment-line>* <?{ $/.chars > 0 }>
#   }
document-prefix:
    bom? comment-line*
#   token bom {
#     "\x[FEFF]"
#   }
bom: / \xEE\xFF /
#   token comment-line {
#     <.space>* <.comment> <.line-end>
#   }
comment-line: SPACE* comment EOL
#   token line-end {
#     <line-break> | $
#   }
line-end: /(: EOL | EOS )/
#   token document-suffix {
#     <.document-end> <.comment>? <.line-end> <.comment-line>*
#   }
document-suffix: document-end comment? line-end comment-line*
#   token any-document {
#     | <directive-document>
#     | <explicit-document>
#     | <bare-document>
#   }
any-document:
    | directive-document
    | explicit-document
    | bare-document
#   token directive-document {
#     <directives>
#     {  }
#     :my %*yaml-prefix = %( $<directives>.ast<tags> );
#     <explicit-document>
#   }
directive-document:
    directives
    explicit-document
#   token directives {
#     [ '%' [ <yaml-directive> | <tag-directive> ] <.space>* <.line-break> ]+
#   }
directives: / ( PERCENT (: yaml-directive | tag-directive ) SPACE* BREAK ) /
#   token yaml-directive {
#     'YAML' <.space>+ $<version>=[ <[0..9]>+ \. <[0..9]>+ ]
#   }
yaml-directive: / 'YAML' SPACE+ ( DIGIT+ '.' DIGITS ) / # ???
#   token tag-directive {
#     'TAG' <.space>+ <tag-handle> <.space>+ <tag-prefix>
#   }
tag-directive: / 'TAG' SPACE+ tag-handle SPACE+ tag-prefix /
#   token tag-prefix {
#     | '!' <.uri-char>+
#     | <.tag-char> <.uri-char>*
#   }
tag-prefix: /(: '!' uri-char+ | tag-char uri-char* )/
#   token explicit-document  {
#     <.directives-end>
#     [
#     | <document=bare-document>
#     | <document=empty-document>
#     ]
#   }
explicit-document:
    directives-end
    (
    | bare-document
    | empty-document
    )
#   token empty-document {
#     <.comment-line>* <?before <document-suffix> | <document-prefix> | $>
#   }
empty-document: 'XXX'
#   token directives-end {
#     '---'
#   }
directives-end: '---'
#   token document-end {
#     '...'
#   }
document-end: '...'
#   token bare-document {
#     [
#     | <.newline> <!before '---' | '...'> <map('')>
#     | <.newline> <list('')>
#     | <.begin-space> <inline>
#     | <.begin-space> <block-string('')>
#     | <.begin-space> <!before '---' | '...'> <plain>
#     ]
#     <.line-end>
#   }
bare-document: 'XXX'
#   token simple-document {
#     <!before '---' | '...'>
#     [
#     | <map('')>
#     | <list('')>
#     | <inline>
#     | <block-string('')>
#     | <plain>
#     ]
#     <.line-end>
#   }
simple-document: inline EOL?
#   token begin-space {
#     <?before <break>> <.ws>
#   }
# 
#   token ws {
#     <.space>*
#     [ [ <!after <.alnum>> <.comment> ]? <.line-break> <.space>* ]*
#   }
#   token block-ws(Str $indent) {
#     <.space>*
#     [ <!after <.alnum>> <.comment> <.line-break> $indent <.space>* ]*
#   }
#   token newline {
#     [ <.space>* <.comment>? <.line-break> ]+
#   }
#   token space {
#     <[\ \t]>
#   }
#   token comment {
#     '#' <-line-break>*
#   }
comment: / HASH '???' /
#   token line-break {
#     <[ \c[LF] \r \r\c[LF]] >
#   }
#   token break {
#     <.line-break> | <.space>
#   }
# 
#   token nb {
#     <[\x09\x20..\x10FFFF]>
#   }
# 
#   token block(Str $indent, Int $minimum-indent) {
#     <properties>?
#     <.newline>
#     :my $new-indent;
#     <?before $indent $<sp>=[' ' ** { $minimum-indent..* } ] { $new-indent = $indent ~ $<sp> }>
#     $new-indent
#     [ <value=list($new-indent)> | <value=map($new-indent)> ]
#   }
# 
#   token map(Str $indent) {
#     <map-entry($indent)>+ % [ <.newline> $indent ]
#   }
#   token map-entry(Str $indent) {
#       <key> <.space>* ':' <?break> <.block-ws($indent)> <element($indent, 0)>
#     | '?' <.block-ws($indent)> <key=.element($indent, 0)> <.newline> $indent
#       <.space>* ':' <.space>+ <element($indent, 0)>
#   }
# 
#   token list(Str $indent) {
#     <list-entry($indent)>+ % [ <.newline> $indent ]
#   }
#   token list-entry(Str $indent) {
#     '-' <?break>
#     [
#       || <element=cuddly-list-entry($indent)>
#       || <.block-ws($indent)> <element($indent, 1)> <.comment>?
#     ]
#   }
#   token cuddly-list-entry(Str $indent) {
#     :my $new-indent;
#     $<sp>=' '+ { $new-indent = $indent ~ ' ' ~ $<sp> }
#     [ <element=map($new-indent)> | <element=list($new-indent)> ]
#   }
# 
#   token key {
#     | <inline-plain>
#     | <single-key>
#     | <double-key>
#   }
key:
    inline-plain
#   token plainfirst {
#     <-[\-\?\:\,\[\]\{\}\#\&\*\!\|\>\'\"\%\@\`\ \t\x0a\x0d]>
#     | <[\?\:\-]> <!before <.space> | <.line-break>>
#   }
plainfirst: /
    [^ '-?:,[]{}#&*!|>"%@`' SINGLE TAB NL CR]
/
#   token plain {
#     <properties>?
#     <.plainfirst> [ <-[\x0a\x0d\:]> | ':' <!break> ]*
#   }
#   regex inline-plain {
#     $<value> = [
#       <.plainfirst> :
#       [ <-[\x0a\x0d\:\,\[\]\{\}]> | ':' <!break> ]*
#       <!after <.space>> :
#     ]
#     <.space>*
#   }
inline-plain: /
    plainfirst (: [^ NL CR COLON COMMA '[]{}' ] | COLON (! WS))* -
/

#   token single-key {
#     "'" $<value>=[ [ <-['\x0a]> | "''" ]* ] "'"
#   }
#   token double-key {
#     \" ~ \" [ <str=.quoted-bare> | \\ <str=.quoted-escape> | <str=.space> ]*
#   }
# 
#   token single-quoted {
#     "'" $<value>=[ [ <-[']> | "''" ]* ] "'"
#   }
#   token double-quoted {
#     \" ~ \" [ <str=.quoted-bare> | \\ <str=.quoted-escape> | <str=foldable-whitespace> | <str=space> ]*
#   }
#   token quoted-bare {
#     <-space-[\"\\\n]>+
#   }
#   token quoted-escape {
#     <["\\/abefnrvtzNLP_\ ]> | x <xdigit>**2 | u <xdigit>**4 | U<xdigit>**8
#   }
#   token foldable-whitespace {
#     <.space>* <.line-break> <.space>*
#   }
#   token block-string(Str $indent) {
#     <properties>?
#     $<kind>=<[\|\>]> <.space>*
#     <.comment>? <.line-break>
#     :my $new-indent;
#     <?before $indent $<sp>=' '+ { $new-indent = $indent ~ $<sp> }>
#     [ $new-indent $<content>=[ \N* ] ]+ % <.line-break>
#   }
# 
#   token yes {
#     [ :i y | yes | true | on ] <|w>
#   }
#   token no {
#     [ :i n | no | false | off ] <|w>
#   }
#   token boolean {
#     <yes> | <no>
#   }
#   token inline-map {
#     '{' <.ws> <pairlist> <.ws> '}'
#   }
inline-map:
    '{' - pairlist - '}'
#   rule pairlist {
    # XXX should use %%. YAML allows trailing comma
#     <pair>* % \,
#   }
pairlist:
    pair* %% COMMA
#   rule pair {
#     <key> ':' [ <inline> || <inline=inline-plain> ]
#   }
pair:
    key - COLON + (inline | inline-plain)
# 
#   token inline-list {
#     '[' <.ws> <inline-list-inside> <.ws> ']'
#   }
inline-list:
    '[' - inline-list-inside - ']'
#   rule inline-list-inside {
#     [ <inline> || <inline=inline-plain> ]* % \,
#   }
inline-list-inside:
    (inline | inline-plain)* %% COMMA
# 
#   token identifier-char {
#     <[\x21..\x7E\x85\xA0..\xD7FF\xE000..\xFFFD\x10000..\x10FFFF]-[\,\[\]\{\}]>+
#   }
#   token identifier {
#     <identifier-char>+ <!before <identifier-char> >
#   }
# 
#   token inline {
#     <properties>?
# 
#     [
#     | <value=int>
#     | <value=hex>
#     | <value=oct>
#     | <value=rat>
#     | <value=float>
#     | <value=inf>
#     | <value=nan>
#     | <value=yes>
#     | <value=no>
#     | <value=null>
#     | <value=inline-map>
#     | <value=inline-list>
#     | <value=single-quoted>
#     | <value=double-quoted>
#     | <value=alias>
#     | <value=datetime>
#     | <value=date>
#     ]
#   }
inline:
| int
| inline-map
| inline-list
| 'XXX'
# 
#   token properties {
#     | <anchor> <.space>+ [ <tag> <.space>+ ]?
#     | <tag> <.space>+ [ <anchor> <.space>+ ]?
#   }
# 
#   token int {
#     '-'?
#     [ 0 | <[1..9]> <[0..9]>* ]
#     <|w>
#   }
int: / '-'? (: 0 | [1-9] DIGIT* ) /
#   token hex {
#     :i
#     '-'?
#     '0x'
#     $<value>=[ <[0..9A..F]>+ ]
#     <|w>
#   }
#   token oct {
#     :i
#     '-'?
#     '0o'
#     $<value>=[ <[0..7]>+ ]
#     <|w>
#   }
#   token rat {
#     '-'?
#     [ 0 | <[1..9]> <[0..9]>* ]
#     \. <[0..9]>+
#     <|w>
#   }
#   token float {
#     '-'?
#     [ 0 | <[1..9]> <[0..9]>* ]
#     [ \. <[0..9]>+ ]?
#     [ <[eE]> [\+|\-]? <[0..9]>+ ]?
#     <|w>
#   }
#   token inf {
#     :i
#     $<sign>='-'?
#     '.inf'
#   }
#   token nan {
#     :i '.nan'
#   }
#   token null {
#     '~'
#   }
#   token alias {
#     '*' <identifier>
#   }
#   token datetime {
#     $<year>=<[0..9]>**4 '-' $<month>=<[0..9]>**2 '-' $<day>=<[0..9]>**2
#     [ ' ' | 'T' ]
#     $<hour>=<[0..9]>**2 '-' $<minute>=<[0..9]>**2 '-' $<seconds>=<[0..9]>**2
#     $<offset>=[ <[+-]> <[0..9]>**1..2]
#   }
#   token date {
#     $<year>=<[0..9]>**4 '-' $<month>=<[0..9]>**2 '-' $<day>=<[0..9]>**2
#   }
# 
#   token element(Str $indent, Int $minimum-indent) {
#     [  [ <value=block($indent, $minimum-indent)> | <value=block-string($indent)> ]
#     |  <value=inline> <.comment>?
#     || <value=plain> <.comment>?
#     ]
#   }
#   token anchor {
#     '&' <identifier>
#   }
# 
#   token tag {
#     | <value=verbatim-tag>
#     | <value=shorthand-tag>
#     | <value=non-specific-tag>
#   }
# 
#   token verbatim-tag {
#     '!<' <uri-char>+ '>'
#   }
#   token uri-char {
#     <char=uri-escaped-char> | <char=uri-real-char>
#   }
uri-char: /(: uri-escaped-char | uri-real-char )/
#   token uri-escaped-char {
#     :i '%' $<hex>=<[ 0..9 A..F ]>**2
#   }
uri-escaped-char: / HASH HEX{2} /
#   token uri-real-char {
#     <[ 0..9 A..Z a..z \-#;/?:@&=+$,_.!~*'()\[\] ]>
#   }
uri-real-char: /[ WORD SINGLE '-#;/?:@&=+$,.!~*()[]' ]/    #'
# 
#   token shorthand-tag {
#     <tag-handle> $<tag-name>=[ <tag-char>+ ]
#   }
#   token tag-handle {
#     '!' [ <[ A..Z a..z 0..9 ]>* '!' ]?
#   }
tag-handle: / '!' ( ALNUM* )' !'? / # ???
#     '!' [ <[ A..Z a..z 0..9 ]>* '!' ]?
#   token tag-real-char {
#     <[ 0..9 A..Z a..z \-#;/?:@&=+$_.~*'() ]>
#   }
tag-real-char: /[ WORD SINGLE '-#;/?:@&=+$.~*()' ]/
#   token tag-char {
#     [ <char=uri-escaped-char> | <char=tag-real-char> ]
#   }
tag-char: /(: uri-escaped-char tag-real-char )/
# 
#   token non-specific-tag {
#     '!'
#   }
# 
#   class Actions {
#     method TOP($/) {
#       make ( @<document>».ast );
#     }
#     method !first($/) {
#       make $/.values.[0].ast;
#     }
#     method any-document($/) {
#       self!first($/);
#     }
#     method directive-document($/) {
#       make $<explicit-document>.ast;
#     }
#     method directives($/) {
#       my %tags = @<tag-directive>».ast;
#       my $version = $<version-directive>.ast // 1.2;
#       make { :%tags, :$version };
#     }
#     method tag-directive($/) {
#       make ~$<tag-handle> => ~$<tag-prefix>
#     }
#     method explicit-document($/) {
#       make $<document>.ast;
#     }
#     method bare-document($/) {
#       self!first($/);
#     }
#     method simple-document($/) {
#       self!first($/);
#     }
#     method empty-document($/) {
#       make Any;
#     }
#     method map($/) {
#       make @<map-entry>».ast.hash;
#     }
#     method map-entry($/) {
#       make $<key>.ast => $<element>.ast
#     }
#     method key($/) {
#       self!first($/);
#     }
#     method list($/) {
#       make @<list-entry>».ast.list;
#     }
#     method list-entry($/) {
#       make $<element>.ast;
#     }
#     method cuddly-list-entry($/) {
#       make $<element>.ast;
#     }
#     method space($/) {
#       make ~$/;
#     }
#     method single-quoted($/) {
#       make $<value>.Str.subst(/<Grammar::foldable-whitespace>/, ' ', :g).subst("''", "'", :g);
#     }
#     method single-key($/) {
#       make $<value>.Str.subst("''", "'", :g);
#     }
#     method double-quoted($/) {
#       make @<str> == 1 ?? $<str>[0].ast !! @<str>».ast.join;
#     }
#     method double-key($/) {
#       self.double-quoted($/);
#     }
#     method foldable-whitespace($/) {
#       make ' ';
#     }
#     method plain($/) {
#       make self!handle_properties($<properties>, $/, ~$/);
#     }
#     method inline-plain($/) {
#       make ~$<value>
#     }
#     method block-string($/) {
#       my $ret = $<content>.map(* ~ "\n").join('');
#       if $<kind> eq '>' {
#         my $/;
#         $ret.=subst(/ <[\x0a\x0d]> <!before ' ' | $> /, ' ', :g);
#       }
#       make self!handle_properties($<properties>, $/, $ret);
#     }
# 
#     method !save($name, $value) {
#       %*yaml-anchors{$name} = $value;
#     }
#     method element($/) {
#       make $<value>.ast;
#     }
# 
#     method inline-map($/) {
#       make $<pairlist>.ast.hash;
#     }
#     method pairlist($/) {
#       make @<pair>».ast.list;
#     }
#     method pair($/) {
#       make $<key>.ast => $<inline>.ast;
#     }
#     method identifier($/) {
#       make ~$/;
#     }
#     method inline-list($/) {
#       make $<inline-list-inside>.ast
#     }
#     method inline-list-inside($/) {
#       make @<inline>».ast.list;
#     }
#     method inline($/) {
#       make self!handle_properties($<properties>, $<value>);
#     }
# 
#     method !decode_value($properties, $ast, $value) {
#       if $properties<tag> -> $tag {
#         return $value if $tag.ast eq '!';
#         my &resolve = %*yaml-tags{$tag.ast} // return die "Unknown tag { $tag.ast }";
#         return resolve($ast, $value);
#       }
#       return $value;
#     }
#     method !handle_properties($properties, $ast, $original-value = $ast.ast) {
#       return $original-value if not $properties;
#       my $value = self!decode_value($properties, $ast, $original-value);
#       self!save($properties<anchor>.ast, $value) if $properties<anchor>;
#       return $value;
#     }
#     method tag($/) {
#       make $<value>.ast;
#     }
#     method verbatim-tag($/) {
#       make @<uri-char>».ast.join('');
#     }
#     method uri-char($/) {
#       make $<char>;
#     }
#     method uri-real-char($/) {
#       make ~$/;
#     }
#     method uri-escaped-char($/) {
#       :16(~$<hex>);
#     }
#     method !lookup-namespace($name) {
#       return %*yaml-prefix{$name} // do given $name {
#         when '!' {
#           '!';
#         }
#         when '!!' {
#           $yaml-namespace;
#         }
#         default {
#           die "No such prefix $name known: " ~ %*yaml-prefix.keys.join(", ");
#         }
#       }
#     }
#     method shorthand-tag($/) {
#       make self!lookup-namespace($<tag-handle>.ast) ~ ~$<tag-name>;
#     }
#     method tag-handle($/) {
#       make ~$/;
#     }
#     method non-specific-tag {
#       make '!';
#     }
# 
#     method inf($/) {
#       make $<sign> ?? -Inf !! Inf;
#     }
#     method nan($/) {
#       make NaN;
#     }
#     method yes($/) {
#       make True;
#     }
#     method no($/) {
#       make False;
#     }
#     method int($/) {
#       make $/.Str.Int;
#     }
#     method hex($/) {
#       make :16(~$<value>);
#     }
#     method oct($/) {
#       make :8(~$<value>);
#     }
#     method rat($/) {
#       make $/.Rat;
#     }
#     method float($/) {
#       make +$/.Str;
#     }
#     method null($/) {
#       make Any;
#     }
#     method alias($/) {
#       make %*yaml-anchors{~$<identifier>.ast} // die "Unknown anchor " ~ $<identifier>.ast;
#     }
#     method datetime($/) {
#       make DateTime.new(|$/.hash».Int);
#     }
#     method date($/) {
#       make Date.new(|$/.hash».Int);
#     }
# 
#     method block($/) {
#       make self!handle_properties($<properties>, $<value>);
#     }
# 
#     method anchor($/) {
#       make $<identifier>.ast;
#     }
# 
#     method quoted-bare ($/) { make ~$/ }
# 
#     my %h = '\\' => "\\",
#         '/' => "/",
#         'a' => "\a",
#         'b' => "\b",
#         'e' => "\e",
#         'n' => "\n",
#         't' => "\t",
#         'f' => "\f",
#         'r' => "\r",
#         'v' => "\x0b",
#         'z' => "\0",
#         '"' => "\"",
#         ' ' => ' ',
#         "\n"=> "\n",
#         'N' => "\x85",
#         '_' => "\xA0",
#         'L' => "\x2028",
#         'P' => "\x2029";
#     method quoted-escape($/) {
#       if $<xdigit> {
#         make chr(:16($<xdigit>.join));
#       } else {
#         make %h{~$/};
#       }
#     }
#   }
# 
#   method parse($string, :%tags, *%args) {
#     my %*yaml-anchors;
#     my %*yaml-tags = |%default-tags, |flatten-tags(%tags);
#     my $*yaml-version = 1.2;
#     my %*yaml-prefix;
#     nextwith($string, :actions(Actions), |%args);
#   }
#   method subparse($string, :%tags, *%args) {
#     my %*yaml-anchors;
#     my %*yaml-tags = |%default-tags, |flatten-tags(%tags);
#     my $*yaml-version = 1.2;
#     my %*yaml-prefix;
#     nextwith($string, :actions(Actions), |%args);
#   }
# }
...

# This is the counterpart to a Perl 6 action class:
package YAMLish::Constructor;
use Pegex::Base;

sub got_yaml_stream {
    return 'yay';
}

1;

#! vim: set lisp:
