package ConfGenCommon;

use strict;
use utf8;

our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(str_to_bash_variable_name put_label_to_file);

sub str_to_bash_variable_name
{
    my $inp = $_[0];
    $inp =~ s/-/_/g;
    return $inp;
}

sub put_label_to_file
{
    my ($fh, $label) = @_[0..1];
    print { $fh } sprintf ("\n###   %s   ###\n", $label);
}

1;
