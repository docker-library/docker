This is a node.js module for minimizing javascript (jsmin for short).

It was originally written by Doug Crockford (www.crockford.com), was ported
to javascript by Franck Marcia (www.fmarcia.info), which in turn was ported
to node.js by Peteris Krumins (www.catonmat.net).

------------------------------------------------------------------------------

The module exports 'jsmin' function:

    var jsmin = require('jsmin').jsmin;

The 'jsmin' function takes three arguments:

    * input js code
    * integer aggressiveness level (defaults to 2)
    * optional comment to prepend to output (defaults to nothing)

The aggressiveness level can be 1, 2 or 3:

    * 1 - keep original newlines in output
    * 2 - original Crockford's algorithm - remove some newlines
    * 3 - remove all newlines

Start the comments that you don't want to remove (as process of minification)
with /*! ... */


Example
-------

    var jsmin = require('./jsmin').jsmin;
    var sys = require('sys');

    sys.puts(jsmin('function    hello( a , b , c ) {   sys.log(a + b + c) }'))

Output:

    'function hello(a,b,c){sys.log(a+b+c)}'


Command-line Usage
------------------

Installing globally (using npm's -g flag) will also install a command-line
tool for using jsmin:

    jsmin [OPTIONS...] [FILENAME]

The input filename should be the last argument. If you don't specify it,
input will be read from STDIN instead.

Supported options:

    -o FILENAME
    --output FILENAME

        Specifies an output file for minified output. If not given, output
        will be written to STDOUT.

    -l LEVEL
    --level LEVEL

        Sets the aggressiveness level to be used.

    -c COMMENT
    --comment COMMENT

        Sets a comment to be prepended to the output.

    --overwrite

        If provided and an input filename was provided (rather than using
        STDIN), output will be written to the same file input was read from.

------------------------------------------------------------------------------

Have fun jsminning!


Sincerely,
Peteris Krumins
http://www.catonmat.net

