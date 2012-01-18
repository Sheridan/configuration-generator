package ConfGenCommon;

use strict;
use utf8;

our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(str_to_bash_variable_name put_label_to_file apply_template put_command_result_to_file range_to_string);

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

sub uniq_array 
{
    return keys %{{ map { $_ => 1 } @_ }};
}

sub combine_array
{
    my ($a, $b) = @_[0..1];
    return uniq_array(@{$a}, @{$b});
    retur $a;
}

sub combine_hash
{
    my ($a, $b) = @_[0..1];
    for my $key (keys %{$b})
    {
	if (not exists ($a->{$key}))
	{
	    $a->{$key} = $b->{$key};
	}
	else
	{
	    if(ref $a->{$key} eq "HASH")
	    {
		$a->{$key} = combine_hash($a->{$key}, $b->{$key});
	    }
	    elsif(ref $a->{$key} eq "ARRAY")
	    {
		$a->{$key} = [combine_array($a->{$key}, $b->{$key})];
	    }
	}
    }
    return $a;
}

sub apply_template
{
    my ($c, $t) = @_[0..1];
    for my $n (keys %{$c})
    {
	if (exists $c->{$n}{'templates'})
	{
	    for my $key (@{$c->{$n}{'templates'}})
	    {
		$c->{$n} = combine_hash($c->{$n}, $t->{$key})
	    }
	    delete $c->{$n}{'templates'};
	}
    }
    return $c;
}

sub put_command_result_to_file
{
    my ($fh, $label, $cmd) = @_[0..2];
    for my $line (`$cmd`)
    {
	chomp $line;
	print { $fh } sprintf("%s	### %s ###\n",$line, $label);
    }
}

sub range_to_string
{
    my ($ranges, $addr_delimiter, $ranges_delimiter) = @_[0..2];
    my $str = "'";
    for ( my $i = scalar(@{$ranges})-1; $i >= 0; $i-- )
    {
	my ($r_from, $r_to) = @{$ranges->[$i]};
	$str .= sprintf("%s%s%s", $r_from, $addr_delimiter, $r_to);
	$str .= $ranges_delimiter if $i != 0;
    }
    return $str . "'";
}

1;
