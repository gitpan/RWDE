## @file
# (Enter your file info here)
# 
# @copy 2007 MailerMailer LLC
# $Id: Mapper.pm 436 2008-05-02 21:05:38Z damjan $

## @class RWDE::Mapper
# (Enter RWDE::Mapper info here)
package RWDE::Mapper;

# Object to handle mapping of the namespaces
# the mapping object translates the call from 
# the local, imported class to the remote namespace
# the convention is $local::$remote -> $remote::$remote

use strict;
use warnings;

use RWDE::Gearman::Client;

use vars qw($AUTOLOAD);

## @cmethod object AUTOLOAD()
# (Enter AUTOLOAD info here)
# @return
sub AUTOLOAD {
  my ($self, $params) = @_;

  $AUTOLOAD =~ m/.*::(.*)::(.*)/;

  my $namespace=$1;
  my $method=$2;

  $$params{method} = $1 .'::' . $1 .'::'.$method;
  
  return RWDE::Gearman::Client->Do_task($params);
}

1;
