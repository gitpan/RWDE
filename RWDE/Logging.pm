package RWDE::Logging;

use strict;
use warnings;

use RWDE::Logger;

sub syslog_msg {
  my ($self, $type, $info) = @_;
                                 
  return RWDE::Logger->syslog_msg($type, $info);
}

sub debug_info {
  my ($self, $type, $info) = @_;

  return RWDE::Logger->debug_info($type, $info);
}

sub is_debug {
  return RWDE::Logger->is_debug;
}


1;
