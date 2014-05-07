package Aca::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    INCLUDE_PATH => [
            Aca->path_to( 'root' ),
        ],
    TIMER              => 0,
    WRAPPER => 'wrapper.tt2',
);

=head1 NAME

Aca::View::HTML - TT View for Aca

=head1 DESCRIPTION

TT View for Aca.

=head1 SEE ALSO

L<Aca>

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
