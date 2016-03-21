#!/usr/bin/perl 

# Created: 03/21/2016 08:52:41 AM
# Last Edit: 2016 Mar 21, 09:13:17 AM
# $Id$

=head1 NAME

foo.pl - test of mod_fcgi from 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;

=head1 SYNOPSIS

Prints environmental variables with mod_fcgi

=cut

use CGI::Fast;


=head1 DESCRIPTION

Testing mod_fcgi, printing environmental variables
from

Linkname: mod_fcgid - Apache HTTP Server Version 2.5
URL: https://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html

Configuration directives

   <Directory /usr/local/apache/fcgi-bin/>
   SetHandler fcgid-script
   Options +ExecCGI
   # Customize the next two directives for your requirements.
   Order allow,deny
   Allow from all
   </Directory>


=cut

while (my $q = CGI::Fast->new) {
    print("Content-Type: text/plain\n\n");
    foreach my $var (sort(keys(%ENV))) {
	my $val = $ENV{$var};
	$val =~ s|\n|\\n|g;
	$val =~ s|"|\\"|g;
	print "${var}=\"${val}\"\n";
    }
}


=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2016 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of foo.pl

# vim: set ts=8 sts=4 sw=4 noet:


