package RWDE::Web::FCGIadapter;

use strict;
use warnings;

use CGI;
use FCGI;

use Error qw(:try);

use RWDE::Exceptions;

use base qw(CGI RWDE::Web::CGIadapter);

our($Ext_Request);

use vars qw($VERSION);
$VERSION = sprintf "%d", q$Revision: 522 $ =~ /(\d+)/;

# workaround for known bug in libfcgi
while ((my $ignore) = each %ENV) { }

# New calls FCGI's accept() method.
sub new {
  my ($proto, $params) = @_;

  my $class = ref($proto) || $proto;

	if ($Ext_Request) {
	  return
  	  unless $Ext_Request->Accept() >= 0;
	} else {
	  return 
  	  unless FCGI::accept() >= 0;
  }

	CGI->_reset_globals;

  my $self = { req => $CGI::Q = $class->SUPER::new($params) };

  bless $self, $class;

  return $self; 
}

# override the initialization behavior so that
# state is NOT maintained between invocations 
sub save_request {
    # no-op
}

sub run {
	my ($self, $params) = @_;

	# it should fork here and enter the blocking while loop
	# for the child only, the parent should make note who
	# got deployed listening to which port and continue monitoring
			
	while (my $req = $self->new()) {
	  try{	
	    RWDE::Web::CommandProxy->execute({ req => $req });
	  }

	  catch Error with{
	    my $ex = shift;

		 $self->syslog_msg('info', "dispatch caught: $ex");
		 $self->syslog_msg('info', "This is beyond unusual, exceptions are caught here to avoid server going down");
	  }
	
	}

 	return();
}


1;
