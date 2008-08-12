package RWDE::Configuration_content;

use strict;

use YAML qw(LoadFile);

use base qw(RWDE::RObject);

our (@fieldnames, %fields, %static_fields, %modifiable_fields, @static_fieldnames, @modifiable_fieldnames);

sub initialize {
  my ($self, $params) = @_;

  # where the config file lives.
  my $config_file = $$params{config_file};

  my %conf = %{ LoadFile($config_file) };

  $self->{_data} = $conf{Service};

  foreach my $field (keys %{ $conf{Service} }) {
    $static_fields{$field} = [ 'char', 'Configuration parameter' ];
  }

  %modifiable_fields = ();

  %fields = (%static_fields, %modifiable_fields);

  @static_fieldnames     = sort keys %static_fields;
  @modifiable_fieldnames = sort keys %modifiable_fields;
  @fieldnames            = sort keys %fields;

  return ();
}

1;
