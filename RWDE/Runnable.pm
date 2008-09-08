package RWDE::Runnable;

use strict;
use warnings;

use Error qw(:try);
use Getopt::Std;
use POSIX qw(:sys_wait_h setsid ceil);

use RWDE::DB::DbRegistry;
use RWDE::Exceptions;

use base qw(RWDE::Logging);

use vars qw($VERSION);
$VERSION = sprintf "%d", q$Revision: 507 $ =~ /(\d+)/;

sub Start {
  my ($self, $params) = @_;

  # Process command line options:
  #  -d turn on debugging (remains in foreground)
  my %opt = ();
  getopts('d:s:m:n:', \%opt);

  RWDE::Logger->set_debug()
    if exists($opt{d});

  my $runnable = $self->new();

  $SIG{INT}    = sub { $runnable->shutdown() };
  $SIG{TERM}   = sub { $runnable->shutdown() };
  $SIG{'USR1'} = sub { $self->toggle_debug(); };

  $runnable->setup(\%opt);

  $self->daemonize()
    unless $self->is_debug;

  $runnable->start();

  return ();
}

sub setup {
  my ($self, $params) = @_;

  #give subclasses a chance to setup

  return ();
}

sub start {
  my ($self, $params) = @_;

  throw RWDE::DevelException({ info => 'start has to be overriden, no work to be done in the abstract clas' });

  return ();
}

sub shutdown {
  my ($self, $params) = @_;

  $self->syslog_msg('info', 'Closing...');

  try {
    my $registry = RWDE::DB::DbRegistry->get_instance();
    $registry->cleanup();
  }

  catch Error with {
    my $ex = shift;

    $self->syslog_msg('info', 'Closing...' . $ex);
  };

  exit(0);
}

# daemonize: From perlipc man page, fork into background and redirect input and output to dev/null
sub daemonize {
  chdir '/' or die "Can't chdir to /: $!";
  open STDIN,  '/dev/null'  or die "Can't read /dev/null: $!";
  open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";
  defined(my $pid = fork) or die "Can't fork: $!";
  exit if $pid;    # parent exits...
  setsid or die "Can't start a new session: $!";
  open STDERR, '>&STDOUT' or die "Can't dup stdout: $!";
  return;
}

1;
