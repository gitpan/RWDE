## @file
# (Enter your file info here)
#
# $Id: Time.pm 438 2008-05-06 14:35:19Z damjan $

## @class RWDE::Time
# (Enter RWDE::Time info here)
package RWDE::Time;

use strict;
use warnings;

use RWDE::DB::Record;
use RWDE::DB::DefaultDB;

use base qw(RWDE::DB::DefaultDB RWDE::DB::Record);

## @method object fetch_time($interval, $timestamp)
# (Enter fetch_time info here)
# @param timestamp  (Enter explanation for param here)
# @param interval  (Enter explanation for param here)
# @return (Enter explanation for return value--(Enter explanation for return value here)--here)
sub fetch_time {
  my ($self, $params) = @_;

  my @required = qw( timestamp interval );
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  #insert regex for timestamp validation and interval validation...

  my $select = 'CAST(? as timestamp) + CAST(? as interval)';
  my @query_params = ($$params{timestamp}, $$params{interval});

  return $self->fetch_single({ select => $select, query_params => \@query_params });
}

## @method object fetch_diff($start_stamp, $stop_stamp)
# (Enter fetch_diff info here)
# @param stop_stamp  (Enter explanation for param here)
# @param start_stamp  (Enter explanation for param here)
# @return (Enter explanation for return value--(Enter explanation for return value here)--here)
# @todo insert regex for timestamp validation and interval validation...
sub fetch_diff {
  my ($self, $params) = @_;

  if (not defined $$params{start_stamp} or not defined $$params{stop_stamp}) {
    return;
  }

  my $select = 'CAST(? as date) - CAST(? as date)';

  my @query_params = ($$params{stop_stamp}, $$params{start_stamp});

  return $self->fetch_single({ select => $select, query_params => \@query_params });
}

## @method object fetch_exact_diff($start_stamp, $stop_stamp)
# (Enter fetch_exact_diff info here)
# @param stop_stamp  (Enter explanation for param here)
# @param start_stamp  (Enter explanation for param here)
# @return (Enter explanation for return value--(Enter explanation for return value here)--here)
sub fetch_exact_diff {
  my ($self, $params) = @_;

  if (not defined $$params{start_stamp} or not defined $$params{stop_stamp}) {
    return;
  }

  #insert regex for timestamp validation and interval validation...

  my $select = "to_char(CAST(? as timestamp) - CAST(? as timestamp),'SS')";

  my @query_params = ($$params{stop_stamp}, $$params{start_stamp});

  return $self->fetch_single({ select => $select, query_params => \@query_params });
}

## @method object now()
# Get the current timestamp. Should be used instead of embedding the call to now from
# an object to keep the object in the correct state
# @return (Enter explanation for return value--(Enter explanation for return value here)--here)
sub now {
  my ($self, $params) = @_;

  return $self->fetch_time({ timestamp => 'NOW()', interval => 0 });
}

## @method object days_passed($timestamp)
# This function returns the number of whole days that have passed since
# date passed in date parameter.
# @param timestamp  (Enter explanation for param here)
# @return (Enter explanation for return value--(Enter explanation for return value here)--here)
sub days_passed {
  my ($self, $params) = @_;

  my $interval = RWDE::Time->fetch_diff({ start_stamp => $$params{timestamp}, stop_stamp => 'now()' });

  # extract the number from the db response with the optional minus
  #$interval =~ m/([-]?\d+)\s+(day)/;

  #my $days = $1;
  #unless (defined($days)) {
  #  $days = 0;
  #}

  return $interval;
}

## @method object format_date($timestamp)
# This function returns a human viewable date
# @param timestamp  (Enter explanation for param here)
# @return (Enter explanation for return value--(Enter explanation for return value here)--here)
sub format_date {
  my ($self, $params) = @_;

  my @required = qw( timestamp );
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  my @parts = split / /, $$params{timestamp};

  my $time = {};
  $$time{date} = $parts[0];
  $$time{time} = $parts[1];

  @parts = split(/-/, $$time{date});

  $$time{year}  = $parts[0];
  $$time{month} = $parts[1];
  $$time{day}   = $parts[2];

  return $time;
}

## @method object format_qdate($timestamp)
# (Enter format_qdate info here)
# @param timestamp  (Enter explanation for param here)
# @return
sub format_qdate {
  my ($self, $params) = @_;

  my @required = qw( timestamp );
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  my $time = $self->format_date({ timestamp => $$params{timestamp} });

  return ("$$time{month}/$$time{day}/$$time{year}");
}

## @method object format_rfc($timestamp)
# This function returns the RFC 822 formatted date - useful for rss where this is required for validation
# @param timestamp  (Enter explanation for param here)
# @return Date
sub format_rfc {
  my ($self, $params) = @_;

  my @required = qw( timestamp );
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  my $select = 'to_char(?::TIMESTAMP WITH TIME ZONE, ?)';
  my @query_params = ($$params{timestamp}, 'Dy, DD Mon YYYY HH12:MI:SS TZ');

  return $self->fetch_single({ select => $select, query_params => \@query_params });
}

## @method object format_human($timestamp)
# This function returns an arbitrary human readable date for use on display pages
# @param timestamp  (Enter explanation for param here)
# @return (Enter explanation for return value--(Enter explanation for return value here)--here)
sub format_human {
  my ($self, $params) = @_;

  my @required = qw( timestamp );
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  my $select = 'to_char(?::TIMESTAMP WITH TIME ZONE, ?)';
  my @query_params = ($$params{timestamp}, 'YYYY-MM-DD HH12:MI:SS TZ');

  return $self->fetch_single({ select => $select, query_params => \@query_params });
}

sub extract_dow {
  my ($self, $params) = @_;
  my @required = qw( timestamp );
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  my $select       = 'EXTRACT(DOW FROM ?::timestamp)';
  my @query_params = ($$params{timestamp});

  return $self->fetch_single({ select => $select, query_params => \@query_params });
}

#Take a timestamp from the database and make it look nice for
#humans to read.  mostly for Postgres which tacks on a numeric timezone.
sub db_format_timestamp {
  my ($self, $db_timestamp) = @_;

  return substr $db_timestamp, 0, 19;
}

1;
