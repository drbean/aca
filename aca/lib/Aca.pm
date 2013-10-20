package Aca;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple

 StackTrace

	Authentication
	Authorization::Roles

	Session
	Session::Store::DBIC
	Session::State::Cookie
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in aca.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Aca',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
);

__PACKAGE__->config->{'Plugin::Authentication'} = {
   default => {
       class           => 'SimpleDB',
       user_model      => 'dicDB::Player',
       password_type   => 'clear',
   },
};

__PACKAGE__->config->{'Plugin::Session'} = {
		dbic_class	=> 'DB::Session',
		expires	=> 3600
};

__PACKAGE__->config(
    default_view => 'HTML',
    'View::HTML' => {
        #Set the location for TT files
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root' ),
        ],
    },
    'View::Email' => {
       stash_key => 'email',
       default => {
           content_type => 'text/plain',
           charset => 'utf-8'
       },
       sender => {
           mailer => 'SMTP',
           mailer_args => {
    	   Host     => 'smtp.example.com',
    	   username => 'username',
    	   password => 'password',
       }
     }
}
);
# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

Aca - Catalyst based application

=head1 SYNOPSIS

    script/aca_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Aca::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
