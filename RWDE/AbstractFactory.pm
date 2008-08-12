package RWDE::AbstractFactory;

# Abstract Factory, instantiates and returns any App object

use strict;
use warnings;

use Error qw(:try);
use RWDE::Exceptions;

sub instantiate {
  my ($self, $params) = @_;

  throw RWDE::DevelException({ info => 'AbstractFactory::Parameter error - class not specified' }) unless ($$params{'class'});

  my $proto = $$params{class};

  my $requested_type = ref $proto || $proto;

  delete $$params{class};

  my $library = $requested_type . '.pm';

  $library =~ s/::/\//g;

  require $library;

  return $requested_type->new($params);
}

1;
