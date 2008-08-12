## @file
# (Enter your file info here)
#
# @copy 2007 MailerMailer LLC
# $Id: RObject.pm 445 2008-05-07 17:43:24Z damjan $

## @class RWDE::RObject
# Base class for variousrecords
# All derived classes must be hashes and correspond to a standard derived class format

package RWDE::RObject;

use strict;
use warnings;

use Data::Validate::Domain qw(is_domain);
use Mail::RFC822::Address qw(valid);

use RWDE::Exceptions;

use base qw(RWDE::Logging);

our (%_validators);

BEGIN {

  #all of the default data validators that we use
  %_validators = (

    # Field => [Type, Callback, Descr]
    IP      => [ 'IP',      'validate_ip',      'validate an ip address' ],
    email   => [ 'email',   'validate_email',   'validate an email address' ],
    boolean => [ 'boolean', 'validate_boolean', 'validate a boolean string' ],
  );
}

## @cmethod object new()
# (Enter new info here)
# @return (Enter explanation for return value here)
sub new() {
  my ($proto, $params) = @_;

  my $class = ref($proto) || $proto;

  my $self = { _data => {}, };

  bless($self, $class);

  no strict 'refs';
  $self->{_modifiable_fields}     = \%{ $class . "::modifiable_fields" };
  $self->{_modifiable_fieldnames} = \@{ $class . "::modifiable_fieldnames" };
  $self->{_static_fields}         = \%{ $class . "::static_fields" };
  $self->{_static_fieldnames}     = \@{ $class . "::static_fieldnames" };
  $self->{_fieldnames}            = \@{ $class . "::fieldnames" };
  $self->{_fields}                = \%{ $class . "::fields" };
  $self->{_id}                    = ${ $class . "::id" };

  $self->initialize($params);

  return $self;
}

## @method object is_instance()
# (Enter is_instance info here)
# @return (Enter explanation for return value here)
sub is_instance {
  my ($self, $params) = @_;

  return ref($self) ? 1 : 0;
}

## @method void check_object($info)
# (Enter check_object info here)
# @param info  (Enter explanation for param here)
sub check_object {
  my ($self, $params) = @_;

  my $info = $$params{info} || "$self is not an instance.";

  if (not $self->is_instance()) {
    my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(1);
    throw RWDE::DevelException({ info => $info . "Called from $subroutine at $package, line: $line" });
  }

  return ();
}

## @method object field_desc()
# Return the field description from the %fields hash for the named field.
# @return (Enter explanation for return value here)
sub field_desc {
  my $self = shift;
  my $fn   = shift;

  return (exists $self->{_fields}->{$fn} ? $self->{_fields}->{$fn}[1] : $fn);
}

## @method object field_type()
# (Enter field_type info here)
# @return (Enter explanation for return value here)
sub field_type {
  my $self = shift;
  my $fn   = shift;

  return $self->{_fields}->{$fn}[0];
}

## @cmethod object FIELDNAME()
# All field names of the record are accessible via the field name.  If a
# second parameter is provided, that value is stored as the data,
# otherwise the existing value if any is returned.  Throws an 'undef'
# exception on error.  It is intended to be called by an F<AUTOLOAD()>
# method from the subclass.
#
# Example:
#
#  $rec->owner_email('new\@add.ress');
#  $rec->user_addr2(undef);
#  print $rec->user_fname();
#
# Would be converted by F<AUTOLOAD()> in the subclass to calls like
#
#  $rec->FIELDNAME('owner_email','new@add.ress');
#
# and so forth.
# @return (Enter explanation for return value here)
sub FIELDNAME {
  my $self           = shift;
  my $fn             = shift;
  my $supplied_value = $_[0];

  $self->check_object({ info => "No method by name: $fn could be located. FIELDNAME tried to find the attribute  by $fn - but the call was on $self, not an instance." });

  $fn =~ s/.*://;    # strip fully-qualified portion

  unless (exists $self->{_fields}->{$fn}) {
    my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(1);
    throw RWDE::DevelException({ info => "Unknown field name '$fn' in class $self, for $package on line: $line." });
  }

  my $type = $self->field_type($fn);    #note the type

  if (not defined $type) {
    throw RWDE::DevelException({ info => "Type for $self -> $fn not defined" });
  }

  if ( defined $supplied_value
    && defined $self->{_data}->{$fn}
    && $type           eq 'timestamp'
    && $supplied_value eq 'date') {
    return substr($self->{_data}->{$fn}, 0, 10);
  }

  #if you are trying to set data, have a name and the data...
  if (defined($supplied_value)) {

    #check to see if the field is modifiable
    if (!(exists $self->{_modifiable_fields}->{$fn})) {
      throw RWDE::DevelException({ info => "Field name '$fn' in class $self is not allowed to be modified." });
    }

    #check to make sure the data is valid to be entered
    if (exists $_validators{$type}) {
      my $callback = $_validators{$type}[1];
      $self->$callback($supplied_value);
    }

    #set the data
    $self->{_data}->{$fn} = $supplied_value;
  }

  return $self->{_data}->{$fn};
}
## @method void validate_email()
# Check the syntactical format of an email address to reduce risk of
# bogus addresses.  Return empty string if OK, otherwise return the error
# message we should display.
#
# Ensures that the address is in somewhat reasonable domain style, does
# not contain blanks, commas, brackets, colons, semicolons, or end in a
# period.

sub validate_email {
  my ($self, $addr) = @_;

  if (length($addr) > 100) {
    throw RWDE::DataBadException({ info => 'Email address is too long.  We only allow 100 characters.' });
  }

  my ($email, $domain) = split /@/, $addr;

  throw RWDE::DataBadException(
    {
      info =>
        'Unfortunately, we are having problems recording your entries and setting up your account. Please check that the email address you entered is in the standard format of "me@example.com" and that it doesn\'t contain any spaces, commas, parentheses, brackets, colons, double quotes, or semicolons and try again.'
    }
  ) unless is_domain($domain);

  throw RWDE::DataBadException(
    {
      info =>
        'Unfortunately, we are having problems recording your entries and setting up your account. Please check that the email address you entered is in the standard format of "me@example.com" and that it doesn\'t contain any spaces, commas, parentheses, brackets, colons, double quotes, or semicolons and try again.'
    }
  ) unless valid($addr);

  return ();
}

## @method void validate_ip()
# Validates the format of a dotted quad IP address.
sub validate_ip {
  my ($self, $ip) = @_;

  my @values = split /\./, $ip;

  my $validity = 0;
  foreach my $value (@values) {
    if (($value > 0) && ($value < 256)) {
      $validity++;
    }
  }

  if ($validity != 4) {
    throw RWDE::DevelException({ info => 'Invalid format for IP address (aaa.bbb.ccc.ddd)' });
  }

  return;
}

## @method void validate_boolean()
# Validates a potential boolean input.
sub validate_boolean {
  my ($self, $boolean) = @_;

  if ( ($boolean ne 'true')
    && ($boolean ne 't')
    && ($boolean ne '1')
    && ($boolean ne 'false')
    && ($boolean ne 'f')
    && ($boolean ne '0')
    && ($boolean ne 'NULL')) {
    throw RWDE::DevelException({ info => 'Invalid boolean expression: ' . $boolean });
  }

  return;
}

## @cmethod void DESTROY()
# do nothing.  here just to shut up TT when AUTOLOAD is present
sub DESTROY {

}

## @method void display()
# (Enter display info here)
sub display {
  my ($self, $params) = @_;

  my $data = $self->get_data;

  foreach my $key (sort keys(%{$data})) {
    print "$key\t";
    print defined $data->{$key} ? ":" . $data->{$key} . ":" : 'Not defined (NULL)';
    print "\n";
  }

  return ();
}

use vars qw($AUTOLOAD);

## @cmethod object AUTOLOAD()
# All field names of the record are accessible via the field name.  If a
# parameter is provided, that value is stored as the data, otherwise the
# existing value if any is returned.  Throws an 'undef' exception on
# error.
#
# Example:
#
#  $rec->password('blahblah');
#  print $rec->password();
# @return (Enter explanation for return value here)
sub AUTOLOAD {
  my ($self, @args) = @_;

  if (not ref $self) {
    my ($package, $filename, $line) = caller();
    throw RWDE::DevelException(
      { info => "Record::AUTOLOAD invoked with the fieldname: $AUTOLOAD; probably static access to an undefined field/method from $filename Line: $line " . join(':', @args) . "\n" });
  }

  return $self->FIELDNAME($AUTOLOAD, @args);
}

sub copy_record {
  my ($self, $source) = @_;

  $self->check_object();

  if ((ref $self) ne (ref $source)) {
    throw RWDE::DevelException({ info => "Cannot copy $source to $self, they have to be of the same type" });
  }

  #copy over all the fields
  foreach my $fieldname (@{ $self->{_fieldnames} }) {

    #populate all the fields
    $self->{_data}->{$fieldname} = $source->$fieldname;
  }

  return;
}

=pod

=head2 fill

Fill an object with data specified in the params hash. If the params hash does not have
every piece of data, an exception is thrown.

=cut

sub fill {
  my ($self, $params) = @_;

  $self->check_object();

  #check to make sure we have all the necessary fields
  foreach my $fieldname (@{ $self->{_fieldnames} }) {
    throw RWDE::DevelException({ info => "Value for the required field $fieldname not found in params hash." })
      unless exists($$params{$fieldname});

    #populate the field
    $self->{_data}->{$fieldname} = $self->denormalize($fieldname, $$params{$fieldname});
  }

  return;
}

=pod

=head2 fill_required

This function takes the required array of elements, populates the current object and notifies if there are any missing elements

=cut

sub fill_required {
  my ($self, $params) = @_;

  my @required = @{ $$params{required} };

  foreach my $f (@required) {
    if (not defined($$params{$f})) {
      $self->add_missing({ key => $f });
    }
    else {
      $self->$f($$params{$f});
    }
  }

  # verify data looks ok...
  $self->is_missing();

  return ();
}

=pod

=head2 fill_optional

This function takes the required array of elements, populates the current object and notifies if there are any missing elements

=cut

sub fill_optional {
  my ($self, $params) = @_;

  my @optional = @{ $$params{optional} };

  foreach my $f (@optional) {
    if (defined($$params{$f})) {
      $self->$f($$params{$f});
    }
  }

  return ();
}

## @method object get_id()
# (Enter get_id info here)
# @return (Enter explanation for return value here)
sub get_id {
  my ($self, $params) = @_;

  my $id_name = $self->get_id_name();

  return $self->$id_name;
}

## @method object get_id_name()
# (Enter get_id_name info here)
# @return (Enter explanation for return value here)
sub get_id_name {
  my ($self, $params) = @_;

  return $self->get_static({ value => '_id' });
}

## @method void fetch_by_id()
# (Enter fetch_by_id info here)
sub fetch_by_id {
  my ($self, $params) = @_;

  #this element is used to lookup static variables for the given type
  my $term = $self->new();

  throw RWDE::DevelException({ info => 'Called with no initialization parameter (has to be ' . $term->get_id_name() . ')' })
    unless (defined $$params{ $term->get_id_name() });

  return $term->_fetch_by_id({ $term->get_id_name() => $$params{ $term->get_id_name() } });
}

sub _fetch_by_id {
  my ($self, $params) = @_;

  return $self->__fetch_by_id($params);

}

## @method object get_static($value)
# (Enter get_static info here)
# @param value  (Enter explanation for param here)
# @return (Enter explanation for return value here)
sub get_static {
  my ($self, $params) = @_;

  my $value;

  my $key = $$params{value};

  if (ref $self) {
    $value = $self->{$key};
  }
  else {
    my $term = $self->new();
    $value = $term->{$key};
  }

  return $value;
}

1;
