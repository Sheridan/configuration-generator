#!/usr/bin/perl

use strict;
#use Data::Dumper;
do "/etc/configuration-generator/lightsquid.aggr.conf"; our $config;

sub url_aggregate($) 
{
    my $url = @_[0];
    $url=~s/$$_[0]/$$_[1]/ for @$config;
    return $url;
}

#print "${ARGV[0]}\n";
#print (url_aggregate ($ARGV[0])); print "\n";
#print Dumper($urlconf);
