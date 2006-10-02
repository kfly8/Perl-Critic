##################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
# ex: set ts=8 sts=4 sw=4 expandtab
##################################################################

package Perl::Critic::Policy::BuiltinFunctions::ProhibitStringySplit;

use strict;
use warnings;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = 0.20;

#----------------------------------------------------------------------------

my $desc = q{String delimiter used with "split"};
my $expl = q{Express it as a regex instead};

#----------------------------------------------------------------------------

sub default_severity { return $SEVERITY_LOW }
sub applies_to { return 'PPI::Token::Word' }

#----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;

    return if $elem ne 'split';
    return if ! is_function_call($elem);

    my @args = parse_arg_list($elem);
    my $pattern = @args ? $args[0]->[0] : return;

    if ( $pattern->isa('PPI::Token::Quote') && $pattern->string() ne $SPACE ) {
        return $self->violation( $desc, $expl, $elem );
    }

    return;  #ok
}


1;

__END__

#------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::BuiltinFunctions::ProhibitStringySplit

=head1 DESCRIPTION

The C<split> function always interprets the PATTERN argument as a
regular expression, even if you specify it as a string.  This causes
much confusion if the string contains regex metacharacters.  So for
clarity, always express the PATTERN argument as a regex.

  $string = 'Fred|Barney';
  @names = split '|', $string; #not ok, is ('F', 'r', 'e', 'd', '|', 'B', 'a' ...)
  @names = split m/[|]/, $string; #ok, is ('Fred', Barney')

When the PATTERN is a single space the C<split> function has special
behavior, so Perl::Critic forgives that usage.  See C<"perldoc -f
split"> for more information.

=head1 SEE ALSO

L<Perl::Critic::Policy::ControlStrucutres::RequireBlockGrep>

L<Perl::Critic::Policy::ControlStrucutres::RequireBlockMap>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut