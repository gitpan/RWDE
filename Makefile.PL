#! /usr/pkg/bin/perl
# $Id: Makefile.PL 510 2008-09-08 23:43:18Z kamelkev $
use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME => 'RWDE',
	      PREREQ_PM => {
		  'Apache::Session' => 0,
		  'Cache::Memcached' => 0,
		  'Crypt::CBC' => 0,
		  'Crypt::Rijndael' => 1.05,
		  'Data::Dumper' => 0,
		  'Data::Validate::Domain' => 0,
		  'DBD::Pg' => 2.6,
		  'Digest::HMAC_SHA1' => 0,
		  'Digest::MD5' => 0,
		  'Error' => 0,
		  'Gearman::Client' => 0,
		  'Gearman::Worker' => 0,
		  'LWP::UserAgent' => 0,
		  'Mail::RFC822::Address' => 0,
		  'MIME::Base64' => 0,
	          'NEXT' => 0,	# part of 5.8; module in 5.10
		  'Net::SMTP' => 0,
		  'Net::Server' => 0,
		  'SCGI' => 0,
		  'Storable' => 0,
		  'Sys::Syslog' => 0,
		  'Template' => 0,
		  'YAML' => 0,
	      },
	      dist => {
		  PREOP => 'pod2text RWDE.pm > README',
	      },
#	      EXE_FILES => [ 'bin/tpage', 'bin/ttree' ],
	      VERSION => sprintf "%d", q$Revision: 510 $ =~ /(\d+)/
	      );
