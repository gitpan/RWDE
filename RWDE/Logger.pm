## @file
# (Enter your file info here)
#
# $Id: Logger.pm 450 2008-05-07 19:31:45Z damjan $

## @class RWDE::Logger
# This namespace exports methods that maybe be imported by any RWDE project.
# These methods provide support for logging via syslog.
# -
# The above functionality is categorized into 3 separate export tags:
#   - Provides error and terminate methods
# :LOG   - Provides$self->syslog_msg, terminate and debug_info methods
# -
# Invoking all of the above methods would involve an import call within your RWDE class like:
# 
package RWDE::Logger;

use strict;
use warnings;

use Error qw(:try);
use Sys::Syslog qw(:standard :extended :macros);

use RWDE::Configuration;
use RWDE::Exceptions;

our ($debug, $syslog_socket);

## @method void set_debug()
# Method to enable debug mode
sub set_debug {
  $debug = 1;
  return;
}

## @method void toggle_debug()
# Method to toggle debug mode
sub toggle_debug {
  $debug = ($debug ? 0 : 1);
  return;
}

## @method object is_debug()
# Method to determine if debug mode is currently set
# @return current debug status
sub is_debug {
  return $debug;
}

## @method protected void _init_syslog()
# Open the syslog connection defined within the Configuration file
sub _init_syslog {

  # open syslog connection
  my $result = setlogsock 'unix';

  if (not defined $result) {
    throw RWDE::DevelException({ info => 'Could not connect to syslog facility' });
  }

  $syslog_socket = $result;

  my $log_filename = lc(RWDE::Configuration->ServiceName);
  openlog($log_filename, 'cons,pid', LOG_LOCAL0);

  return ();
}

## @method void$self->syslog_msg()
# Log a message to syslog via the established syslog connection
# A type and info are required
# @param type is one of debug, info, notice, warning, err, crit, alert, emerg
# @param info is the desired log message
#TODO properly get the params here
sub syslog_msg {
  my ($self, $type, $info) = @_;

  if (!($syslog_socket)) {
    _init_syslog();
  }

  my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(1);

  my %valid_level = (
    debug   => 1,
    info    => 1,
    notice  => 1,
    warning => 1,
    err     => 1,
    crit    => 1,
    alert   => 1,
    emerg   => 1
  );

  if (not defined $valid_level{$type}) {
    $type = 'info';
  }

  if (not defined $info) {
    my ($package, $filename, $line) = caller(1);
    $info = "No message sent to syslog from $filename Line: $line!";
  }

  if (defined($package) && defined($subroutine)) {
    $info = "$package=>$subroutine ($info)";
  }

  syslog($type, '%s', $info);

  debug_info($type, $info);

  return;
}

## @method void debug_info()
# take the type and the human readable message and print it to STDERR if debug is on
sub debug_info {
  my ($type, $info) = @_;

  if ($debug) {
    my $d = scalar localtime;
    print "$d: $type -- $info\n";
  }

  return ();
}

1;
