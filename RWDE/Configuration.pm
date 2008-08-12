package RWDE::Configuration;

use strict;

use YAML qw(LoadFile);

use RWDE::Configuration_content;

use base qw(RWDE::Singleton);

our $unique_instance;
our (@fieldnames, %fields, %static_fields, %modifiable_fields, @static_fieldnames, @modifiable_fieldnames);

#TODO Move this method to RWDE::Singleton
sub get_instance {
  my ($self, $params) = @_;

  if (ref $unique_instance ne $self) {
    $unique_instance = $self->new($params);
  }

  return $unique_instance;
}

sub initialize {
  my ($self, $params) = @_;

  my $configuration_content = RWDE::Configuration_content->new($params);

  $self->{_configuration_content} = $configuration_content;

  return ();
}

sub get_SMTP {
  my ($self, $params) = @_;

  my $array_ref = $self->SMTPhost;

  return $$array_ref[ rand @{$array_ref} ];
}

sub get_root {
  my ($self, $params) = @_;

  return '/web/' . lc(RWDE::Configuration->ServiceName);
}

use vars qw($AUTOLOAD);

## @cmethod object AUTOLOAD()
# We catch configuration calls, so we can proxy them to the content provider
# @return (Enter explanation for return value here)
sub AUTOLOAD {
  my ($self, @args) = @_;

  return $self->FIELDNAME($AUTOLOAD, @args);
}

## @cmethod object FIELDNAME()
# This is a wrapper function for Configuration content so that the calls can look like they are static
# due to this object being a singleton, there's no multiple configuration loaded
# @return (Enter explanation for return value here)
sub FIELDNAME {
  my $self = shift;
  my $fn   = shift;

  $fn =~ s/.*://;    # strip fully-qualified portion

  my $instance = ref $self ? $self : $self->get_instance();
  my $configuration_content = $instance->{_configuration_content};

  return $configuration_content->$fn;
}

1;
