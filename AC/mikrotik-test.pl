#!/usr/bin/perl -w
use strict;
use lib '/lcs/include';
use Data::Dumper;
use vars qw($error_msg $debug);
use Mtik;
use MtikAC;

#MtikAC->create_config();
#MtikAC->setPassword();
#MtikAC->setHostname();
#MtikAC->checkFirmware();
MtikAC->getResources();
