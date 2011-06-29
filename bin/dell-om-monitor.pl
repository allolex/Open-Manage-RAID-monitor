#!/usr/bin/env perl
use strict;
use warnings;

my @disks;

my $controller = shift || '0';

my $command = "/opt/dell/srvadmin/bin/omreport storage pdisk controller=$controller";
my $report;

# Generic parsing to get all the values into data structures
if ( $report = `$command` ) {
	my @entries = split /\n\n/, $report;
	#print "[[[$_]]]\n\n" foreach @entries;
	foreach my $entry ( @entries) {
		next unless $entry =~ /:/;
		my %diskinfo;
		my @lines = split /\n/,$entry;
		foreach my $line ( @lines ) {
			next unless $line =~ /:/;
			my @data = split /\s*: (?!=.*?:)/,$line;
			foreach ( @data ) {
				s/^\s+|\s+$//g; 
				undef $_ if /^\s*$/;
			}
			$data[0] =~ s/\s+/_/g;
			$diskinfo{ lc($data[0]) } = $data[1] ? $data[1] : 'EMPTY STRING';
		}
		push @disks, \%diskinfo;
	}

}
else {
	die "Error executing omreport:\n\t$command\n";
}

# Look for specific data here
foreach my $disk ( @disks ) {
		#print all the keys/values
		#print map { "$_\t: $disk->{$_}\n" } sort keys %$disk;

		# Find potential disk failures
		if ( $disk->{"failure_predicted"} =~ /yes/i ) {
			print "Drive failure predicted on disk ID: " . $disk->{"id"} . "\n";
		}
}
	

