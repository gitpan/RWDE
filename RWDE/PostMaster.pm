package RWDE::PostMaster;

use strict;
use warnings;

use base qw( RWDE::Singleton );

use Template;

use Net::SMTP;

use RWDE::Configuration;

my $unique_instance;

sub get_instance {
  my ($self, $params) = @_;

  if (ref $unique_instance ne $self) {
    $unique_instance = $self->new;
  }

  return $unique_instance;
}

sub initialize {
  my ($self, $params) = @_;

  $self->{server} = RWDE::Configuration->get_SMTP();

  # create template object for future use
  $self->{template} = Template->new(
    {
      TAG_STYLE    => 'asp',
      PROCESS      => 'message.tt',
      INCLUDE_PATH => RWDE::Configuration->get_root . '/templates/emailmessages',
      VARIABLES    => {
        commify => \&RWDE::Utility::commify,
        global  => RWDE::Configuration->get_instance,
      },
    }
  ) or throw RWDE::DevelException({ info => 'Template::new failure.' });

  return ();
}

=pod

=head2 send_message ($smtp_sender, $smtp_recipient, $template)

Prepare or send a 1-to-1 message to the $smtp_recipient address, from $smtp_sender address, using $template as a template input
and the $params to populate the template. To alter the header from/to etc, edit the template.

=cut

sub send_message {
  my ($self, $params) = @_;

  my @required = qw( smtp_sender smtp_recipient template );
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  # Process the message thru the Template
  my $output;

  my $postmaster = RWDE::PostMaster->get_instance();

  my $template = $postmaster->{template};

  unless ($template->process($$params{template}, $params, \$output)) {
    throw RWDE::DevelException({ info => $template->error() });
  }

  my $mh = new Net::SMTP($postmaster->{server})
    or throw RWDE::DevelException({ info => 'PostMaster::CONNECT failure ' . $postmaster->{server} });

  $mh->mail($$params{smtp_sender})
    or throw RWDE::DevelException({ info => 'PostMaster::SMTP FROM failure: ' . $postmaster->{server} . '::' . $mh->message() });

  $mh->recipient($$params{smtp_recipient})
    or throw RWDE::DevelException({ info => 'PostMaster::SMTP TO failure: ' . $postmaster->{server} . '::' . $mh->message() . ' for: ' . $$params{smtp_recipient} });

  $mh->data()
    or throw RWDE::DevelException({ info => 'PostMaster::DATA failure: ' . $postmaster->{server} . '::' . $mh->message() });
  $mh->datasend("Errors-To:$$params{smtp_sender}\n")
    or throw RWDE::DevelException({ info => 'PostMaster::DATASEND failure: ' . $postmaster->{server} . '::' . $mh->message() });
  $mh->datasend($output)
    or throw RWDE::DevelException({ info => 'PostMaster::DATASEND failure: ' . $postmaster->{server} . '::' . $mh->message() });

  $mh->dataend()
    or throw RWDE::DevelException({ info => 'PostMaster::DATA END failure, message NOT sent: ' . $postmaster->{server} . '::' . $mh->message() });

  $mh->quit();

  return ();
}

sub send_verp_message {
  my ($self, $params) = @_;

  my @failed;

  my @required = qw( smtp_sender recipients template);
  RWDE::DB::Record->check_params({ required => \@required, supplied => $params });

  my $postmaster = RWDE::PostMaster->get_instance();

  my @recipients = @{ $$params{recipients} };
  if (!(@recipients > 0)) {
    return;
  }

  # Process the message through the Template
  my $output;
  my $template = $postmaster->{template};

  unless ($template->process($$params{template}, $params, \$output)) {
    throw RWDE::DevelException({ info => $template->error() });
  }

  my $mh = new Net::SMTP($postmaster->{server})
    or throw RWDE::DevelException({ info => 'PostMaster::CONNECT failure' });

  #Limit to 1000 recipients per connection
  # if we get more, just bucketize them

  $mh->mail($$params{smtp_sender}, XVERP => 1)
    or throw RWDE::DevelException({ info => 'PostMaster::SMTP XVERP failure: ' . $mh->message() });

  my @good_recipients = $mh->recipient(@recipients, { SkipBad => 1 }) or ();

  $mh->data()
    or throw RWDE::DevelException({ info => 'PostMaster::DATA failure: ' . $mh->message() });

  $mh->datasend($output)
    or throw RWDE::DevelException({ info => 'PostMaster::DATASEND failure: ' . $mh->message() });

  $mh->dataend()
    or throw RWDE::DevelException({ info => 'DATA END failure, message NOT sent: ' . $postmaster->{server} . '::' . $mh->message() });

  $mh->quit();

  return \@good_recipients;
}

sub send_support_message {
  my ($self, $params) = @_;

  my $topic = $$params{topic}
    or throw RWDE::DataBadException({ info => 'No topic selected. Please select a topic so we can route your message properly' });

  my $question = $$params{question}
    or throw RWDE::DataBadException({ info => 'Sorry, we didn\'t receive your message.  Please try sending it again.' });

  $self->send_message(
    {
      smtp_sender    => RWDE::Configuration->Sender,
      smtp_recipient => RWDE::Configuration->$topic,
      template       => 'support.tt',

      #-- template params
      params => $params,
    }
  );

  return ();
}

sub send_report_message {
  my ($self, $params) = @_;

  $$params{smtp_sender}    = RWDE::Configuration->Sender;
  $$params{smtp_recipient} = RWDE::Configuration->ErrorReport;
  $$params{template}       = 'report.tt';

  $self->send_message($params);

  return ();
}

1;
