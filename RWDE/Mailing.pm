package RWDE::Mailing;

# Mailing interface for objects that can receive emails.
# provides throttling by keeping daily count of emails sent 

use strict;
use warnings;

  

## @method object get_email()
# (Enter get_email info here)
# @return (Enter explanation for return value here)
sub get_email {
  my ($self, $params) = @_;

  my $email_field = $self->{_email};

  throw RWDE::DevelException({ info => " $self does not have an email address" })
    unless defined $email_field;

  return $self->$email_field;
}

sub send_message{
	my ($self, $params) = @_;

	my $class = ref $self || $self;
	
	throw RWDE::DevelException({ info =>"Class $class does not implement send_message" });
	
	return();
}

sub _send_message{
	my ($self, $params) = @_;

	if (defined $$params{user_initiated}){
		$self->check_limit();
		$self->mail_count($self->mail_count+1);
		$self->update_record();
	}
	
  my %loc_params = %{$params}; #copy the hash, to avoid side-effects

  RWDE::PostMaster->send_message($params);

 $self->syslog_msg('devel', 'Sent ' .  $loc_params{template} . ' to ' . $loc_params{smtp_recipient});

	return();	
}

sub check_limit{
	my ($self, $params) = @_;
	
	if ($self->mail_count >= 5){
		throw RWDE::DataLimitException({ info => 'Max number of user inititiated emails reached for today.'});
	}
	
	return();
}

1;

