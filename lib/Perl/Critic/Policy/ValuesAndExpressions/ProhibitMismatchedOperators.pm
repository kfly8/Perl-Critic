##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/Variables/ProtectPrivateVars.pm $
#     $Date: 2006-10-25 21:49:09 -0700 (Wed, 25 Oct 2006) $
#   $Author: thaljef $
# $Revision: 750 $
# ex: set ts=8 sts=4 sw=4 expandtab
##############################################################################

package Perl::Critic::Policy::ValuesAndExpressions::ProhibitMismatchedOperators;
use strict;
use warnings;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = 0.21;

#---------------------------------------------------------------------------

my $desc = q{Mismatched operator};

# operator types

my %op_types = (
    # numeric
    (map { $_ => 0 } qw( == != > >= < <= + - * / += -= *= /= )),
    # string
    (map { $_ => 1 } qw( eq ne lt gt le ge . .= )),
);

# token compatibility [ numeric, string ]

my %token_compat = (
    'PPI::Token::Number' => [ 1, 0 ],
    'PPI::Token::Symbol' => [ 1, 1 ],
    'PPI::Token::Quote'  => [ 0, 1 ],
);

#---------------------------------------------------------------------------

sub default_severity { return $SEVERITY_LOW; }
sub applies_to { return 'PPI::Token::Operator'; }

#---------------------------------------------------------------------------

sub violates {
    my ( $self, $elem ) = @_;

    my $elem_text = "$elem";

    return if !exists $op_types{$elem_text};

    my $prev_elem = $elem->sprevious_sibling();

    # work around PPI operator parsing bugs

    return if $prev_elem->isa('PPI::Token::Operator');

    my $next_elem = $elem->snext_sibling();

    if ( $next_elem->isa('PPI::Token::Operator') ) {
        $elem_text .= $next_elem;
        $next_elem = $next_elem->snext_sibling();
    }

    return if !exists $op_types{$elem_text};
    my $op_type = $op_types{$elem_text};

    my $prev_compat = $self->_get_token_compat( $prev_elem );
    my $next_compat = $self->_get_token_compat( $next_elem );

    return if ( !defined $prev_compat || $prev_compat->[$op_type] )
        && ( !defined $next_compat || $next_compat->[$op_type] );

    return $self->violation( $desc, undef, $elem );
}

#---------------------------------------------------------------------------

# get token value compatibility

sub _get_token_compat {
    my ( $self, $elem ) = @_;

    foreach my $class ( keys %token_compat ) {
        return $token_compat{$class} if $elem->isa($class);
    }

    return;
}

1;

__END__

#---------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::ProhibitMismatchedOperators

=head1 DESCRIPTION

Using the wrong operator type for a value can obscure coding intent and
possibly lead to subtle errors.  An example of this is mixing a string equality
operator with a numeric value, or vice-versa.

  if ($foo == 'bar') {}     #not ok
  if ($foo eq 'bar') {}     #ok
  if ($foo eq 123) {}       #not ok
  if ($foo == 123) {}       #ok

=head1 AUTHOR

Peter Guzis <pguzis@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2006 Peter Guzis.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut