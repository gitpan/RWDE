package RWDE::LoginUser;

use strict;
use warnings;

use RWDE::Configuration;

use Error qw(:try);
use RWDE::Exceptions;



=pod

=head2 authenticate

Given lookup field and the lookup value, validate that
- the entity exists
- the status is operational
- the password credential supplied is matching

=cut


sub Authenticate {
  my ($self, $params) = @_;

  # If the method is not called in the instance context
  # the system has to do a lookup for the instance first
  RWDE::DB::Record->check_params({ required => ['lookup_value', 'password'], supplied => $params });

  my $lookup = $$params{lookup} || $self->get_lookup_field();

  my $term;

  #TODO replace these with one single call to a collective method that just knows what to do
  if ($lookup eq 'admin_login') {
    $term = $self->fetch_by_admin_login({ $lookup => $$params{lookup_value} });
  }
  elsif ($lookup eq 'login_email') {
    $term = $self->fetch_by_login_email({ $lookup => $$params{lookup_value}});
  }
  else {
    $term = $self->fetch_by_id({ $lookup => $$params{lookup_value}});
  }

  $term->authenticate($params);
  
  return $term;
}


sub authenticate {
  my ($self, $params) = @_;

  $self->check_object();
  
  $self->check_password({ password => $$params{password} });
  
  $self->check_status();

  $self->lastlogin(RWDE::Time->now());

  $self->update_record();

  return;
}

=pod

=head2 check_password

Returns true if the 'password' stored in the params hash 
matches that of the current record, false for failed match 
or throws an exception otherwise.

Exceptions classes thrown are C<dberr> on database error or
C<data.missing> for a missing Subscriber ID.

=cut

sub check_password {
  my ($self, $params) = @_;

  if (!defined($$params{password})) {
    throw RWDE::BadPasswordException({ info => "$self supplied incorrect password" });
  }

  elsif ($self->get_password() ne $$params{password}) {
    throw RWDE::BadPasswordException({ info => "$self supplied incorrect password" });
  }

  return ();
}

sub generate_randpass {
  my ($self, $params) = @_;

  my $passwordsize = 8;
  my @alphanumeric = ('a' .. 'z', 'A' .. 'Z', 0 .. 9);
  my $randpassword = join '', map { $alphanumeric[ rand @alphanumeric ] } 0 .. $passwordsize;

  return $randpassword;
}

1;

