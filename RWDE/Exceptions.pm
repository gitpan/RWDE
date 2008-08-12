## @file
# Exception container file, contains definitions for RWDE Exceptions
#
# $Id: Exceptions.pm 432 2008-05-02 19:17:09Z damjan $

## @class RWDE::BaseException
# System defined exceptions are based off of the default behaviour of this base exception class
package RWDE::BaseException;

use strict;
use warnings;

use RWDE::DB::DbRegistry;

use base qw(Error);

use overload ('""' => 'stringify');


## @cmethod object new()
# Override for the "new" method in the Error base class, initializes the instance the way we want
# @return Initialized instance of Error
sub new {
  my ($proto, $params) = @_;

  my $class = ref($proto) || $proto;

  my $info  = defined $$params{info} ? $$params{info} : 'none';
  my $value = defined $$params{value} ? $$params{info} : 'none';

  if (defined $$params{abort_transaction}) {
    RWDE::DB::DbRegistry->abort_transaction();
  }

  local $Error::Depth = $Error::Depth + 1;
  local $Error::Debug = 1;                   # Enables storing of stacktrace

  my $exception = $class->SUPER::new(-text => $info, -value => $value);

  return $exception;
}

sub is_retry {
  my ($self) = @_;

  return $self->{'-value'} =~ m/retry/ig;
}

1;

#Exception class definitions for RWDE

## @class RWDE::DevelException
# devel - caught with RWDE::DevelException - developer only exceptions, typically for unplanned behaviour
package RWDE::DevelException;
use base qw(RWDE::BaseException);

1;

## @class RWDE::DataMissingException
# data.missing - caught with RWDE::DataMissingException - missing data detected
package RWDE::DataMissingException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::DataBadException
# Invalid data detected
package RWDE::DataBadException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::DataLimitException
# Limit or threshold exceeded
package RWDE::DataLimitException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::DataDuplicateException
# Discovered duplicate data (typically db related)
package RWDE::DataDuplicateException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::DataNotFoundException
# Expected data does not exist
package RWDE::DataNotFoundException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::BadPasswordException
# Problems accepting a password
package RWDE::BadPasswordException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::SSLException
# Problems with http SSL connections
package RWDE::SSLException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::Web::SessionMissingException
# Problem with the session occurred
package RWDE::Web::SessionMissingException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::StatusException
# Problem with instance status
package RWDE::StatusException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::DatabaseErrorException
# Internal db problem detected
package RWDE::DatabaseErrorException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::PolicyException
# Policy violation occurred
package RWDE::PolicyException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::PermissionException
# Permission violation occurred
package RWDE::PermissionException;
use base qw(RWDE::BaseException);
1;

## @class RWDE::DefaultException
# Default Exception - undefined exceptions are funnelled here
package RWDE::DefaultException;
use base qw(RWDE::BaseException);
1;
