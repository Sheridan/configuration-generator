package ConfGenCommon;

use strict;
use utf8;

our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(str_to_bash_variable_name put_label_to_file apply_template put_command_result_to_file range_to_string range_to_ip_list);

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

sub range_to_ip_list_internal
{
  my ($octets_from, $octets_to, $start_octet) = @_[0..2];
  my $ip_list = ();
  for (my $a  = ($start_octet >= 0 ? $octets_from->[0] : 1); 
          $a <= ($start_octet >= 0 ? $octets_to->[0] : 254); 
          $a++)
  {
    for (my $b  = ($start_octet >= 1 ? $octets_from->[1] : 1); 
            $b <= ($start_octet >= 1 ? $octets_to->[1] : 254); 
            $b++)
    {
      for (my $c  = ($start_octet >= 2 ? $octets_from->[2] : 1); 
              $c <= ($start_octet >= 2 ? $octets_to->[2] : 254); 
              $c++)
      {
        for (my $d  = ($start_octet >= 3 ? $octets_from->[3] : 1); 
                $d <= ($start_octet >= 3 ? $octets_to->[3] : 254); 
                $d++)
        {
          push (@{$ip_list}, sprintf("%d.%d.%d.%d", $a, $b, $c, $d ));
        }
      }
    }
  }
  return $ip_list;
}

sub range_to_ip_list
{
  my ($ip_from, $ip_to) = @_[0..1];
  my ($octets_from, $octets_to) = ([split(/\./, $ip_from)], [split(/\./, $ip_to)]);
  for (my $i = 0; $i < 4; $i++)
  {
     if($octets_from->[$i] ne $octets_to->[$i])
     {
       return range_to_ip_list_internal($octets_from, $octets_to, $i);
     }
  }
  return [];
}

1;
