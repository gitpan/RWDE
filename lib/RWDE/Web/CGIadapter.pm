## @file
# (Enter your file info here)
#
# @copy 2007 MailerMailer LLC
# $Id: CGIadapter.pm 446 2008-05-07 17:45:44Z damjan $

use vars qw($VERSION);
$VERSION = sprintf "%d", q$Revision: 522 $ =~ /(\d+)/;

## @class RWDE::Web::CGIadapter
# (Enter RWDE::Web::CGIadapter info here)
package RWDE::Web::CGIadapter;

use strict;
use warnings;

use Error qw(:try);
use RWDE::Exceptions;

use base qw(RWDE::Logging);

## @method object get_req()
# (Enter get_req info here)
# @return
sub get_req {
  my ($self, $params) = @_;

  return $self->{req};
}

## @method object is_https()
# (Enter is_https info here)
# @return
sub is_https {
  my ($self, $params) = @_;

  return ($self->get_req->protocol() eq 'https');
}

## @method void check_https()
# (Enter check_https info here)
sub check_https {
  my ($self, $params) = @_;

  unless ($self->is_https()) {
    throw RWDE::DevelException({ info => 'Attempt to access secure information on a non-ssl connection.' });
  }

  return ();
}

## @method object get_uri()
# (Enter get_uri info here)
# @return
sub get_uri {
  my ($self, $params) = @_;

  my $script_name = substr($self->get_req->script_name(), 1);

  #Get script returns the get part of the request if there is a // in it, we only want the script name
  my ($uri, $get_request) = split /\?/, $script_name;

  # get the uri requested
  return $uri;
}

## @method object get_url()
# (Enter get_url info here)
# @return
sub get_url {
  my ($self, $params) = @_;

  # get the uri requested
  return $self->get_req->url();
}

## @method object get_class()
# (Enter get_class info here)
# @return
sub get_class {
  my ($self, $params) = @_;

  my $uri = $self->get_uri();

  my $cpath = (split /\./, $uri)[0];    #the command path

  my @cparts = split /\//, $cpath;

  my $class = join('::', @cparts);

  $class = 'Command::' . $class;

  #replace dashes for underscores
  $class =~ s/-/_/g;

  #sanitize: remove everything that is not allowed in the package name
  # $class =~ /([a-zA-Z0-9_:]+)/;

  return ($class);
}

## @method object get_formdata()
# (Enter get_formdata info here)
# @return
sub get_formdata {
  my ($self, $params) = @_;

  my $formdata = {};

  foreach my $f ($self->get_req->param()) {

    #each param is an array, but there most likely is just one value
    my @ar = $self->get_req->param($f);

    #if this parameter had an array of values
    if (scalar @ar > 1) {

      #pass as reference
      $$formdata{$f} = \@ar;
    }

    #otherwise...
    else {

      #store single value under hash key
      if (defined $ar[0] && $ar[0] ne '--' && $ar[0] ne '' && !($ar[0] =~ m/^\s*$/)) {
        $$formdata{$f} = $ar[0];    #store form data in hash
      }
    }
  }
  return $formdata;
}

## @method void set_cookie($data, $insecure, $name, $uri)
# (Enter set_cookie info here)
# @param name  (Enter explanation for param here)
# @param insecure  (Enter explanation for param here)
# @param data  (Enter explanation for param here)
# @param uri  (Enter explanation for param here)
sub set_cookie {
  my ($self, $params) = @_;

  my $uri  = $$params{uri};
  my $name = $$params{name};
  my $data = $$params{data};
  my $cookie;

  if (!$$params{insecure}) {
    $self->check_https();

    $cookie = $self->get_req->cookie(
      -name    => $name,
      -value   => $data,
      -expires => '+24h',
      -secure  => 1
    );
  }
  else {
    $cookie = $self->get_req->cookie(
      -name    => $name,
      -value   => $data,
      -expires => '+24h',
    );
  }

  $self->forward({ cookie => $cookie, uri => $$params{uri} });

  return ();
}

## @method void print_header($filename, $mimetype, $pagetype)
# (Enter print_header info here)
# @param filename  (Enter explanation for param here)
# @param pagetype  (Enter explanation for param here)
# @param mimetype  (Enter explanation for param here)
sub print_header {
  my ($self, $params) = @_;

  if ($self->{header}) {
    return ();
  }

  my $pagetype = $$params{pagetype};

  # unless (defined $pagetype) {
  #   throw RWDE::DevelException({ info => 'Pagetype is not defined' });
  # }

  #if this is a standard webserver type
  if ($pagetype eq 'rwp') {
    print $self->get_req->header(
      -content_type => 'text/html; charset=utf-8',
      -pragma       => 'no-cache'
    );
    $self->{header} = 'true';
  }

  elsif ($pagetype eq 'ttml') {
    print $self->get_req->header(
      -content_type => 'text/html; charset=utf-8',
      -pragma       => 'no-cache'
    );
    $self->{header} = 'true';
  }

  elsif ($pagetype eq 'rss') {
    print $self->get_req->header(
      -content_type => 'text/xml; charset=utf-8',
      -pragma       => 'no-cache'
    );
    $self->{header} = 'true';
  }

  elsif ($pagetype eq 'bin') {

    # Ignore header printout request for .bin's
    # if all required elements are not set we'll
    # let the command print it out later.
    # This avoids the problem of special casing all
    # standard header printouts.
    if (not defined $$params{filename}) {
      return ();
    }

    print $self->get_req->header(
      -type       => $$params{mimetype},
      -attachment => $$params{filename}
    );
    $self->{header} = 'true';
  }

  return ();
}

## @method void forward($cookie, $uri)
# (Enter forward info here)
# @param cookie  (Enter explanation for param here)
# @param uri  (Enter explanation for param here)
sub forward {
  my ($self, $params) = @_;

  if ($self->{header}) {
    throw RWDE::DevelException({ info => 'Header was already sent to the client, redirect won\'t work' });
  }

  my $uri    = $$params{uri};
  my $cookie = $$params{cookie};
  print $self->get_req->redirect(
    -uri    => $uri,
    -nph    => 0,
    -cookie => $cookie,
    -status => '303 See Other'
  );

  $self->{header}  = 'true';
  $self->{forward} = 'true';

  # 301 - Moved Permanently
  # 302 - Found
  # 303 - See Other
  return ();
}

## @method void auth_required()
# (Enter auth_required info here)
sub auth_required {
  my ($self, $params) = @_;

  if ($self->{header}) {
    throw RWDE::DevelException({ info => 'Header was already sent to the client, redirect won\'t work' });
  }

  print $self->get_req->header(
    -status           => '401 Authorization Required',
    -WWW_authenticate => 'Basic realm="DiscussThis Archives"',
  );

  $self->{header} = 'true';

  # 401 - Authorization Required
  return ();
}

## @method object get_record()
# (Enter get_record info here)
# @return
sub get_record {
  my ($self, $params) = @_;

  my @proof;
  push(@proof, "Time: " . RWDE::Time->now, "Request: " . $self->get_req->script_name(), "IP: " . $self->get_req->remote_host(), "Agent: " . ($self->get_req->user_agent() || 'N/A'));

  my $record .= join("\n", @proof);

  return $record;
}

## @method object get_remote_ip()
# (Enter get_remote_ip info here)
# @return
sub get_remote_ip {
  my ($self, $params) = @_;
  return $self->get_req->remote_host();
}

## @method object get_referer()
# (Enter get_referer info here)
# @return
sub get_referer {
  my ($self, $params) = @_;

  return $self->get_req->referer();
}

## @method object get_contenttype()
# (Enter get_contenttype info here)
# @return
sub get_contenttype {
  my ($self, $params) = @_;

  my $file = $self->get_req->param('upload');

  my $info = $self->get_req->uploadInfo($file);

  return $info->{'Content-Type'};
}

1;

