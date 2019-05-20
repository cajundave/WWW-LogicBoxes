#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::MockModule;

use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::WWW::LogicBoxes::Domain qw( create_domain );
use Test::WWW::LogicBoxes qw( create_api );

use Readonly;
Readonly my $FAKE_ID => -1;

my $logic_boxes = create_api;

subtest 'Verification status for domain that does not exist - throws exception' => sub {
    throws_ok {
        $logic_boxes->verification_status( id => $FAKE_ID );
    }
    qr/No such domain/;
};

subtest 'Verification status for new domain' => sub {
    my $domain = create_domain();
    my $response;
    lives_ok {
        $response = $logic_boxes->verification_status( id => $domain->id );
    }
    'Lives through verification_status request';
    is( $response, 'Pending', 'Responds with Pending' );
};

done_testing;
