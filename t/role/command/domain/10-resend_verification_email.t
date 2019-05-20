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

subtest 'Resend Email Verification For Domain That Does Not Exist - Throws Exception' => sub {
    throws_ok {
        $logic_boxes->resend_verification_email( id => $FAKE_ID );
    }
    qr/No such domain/;
};

subtest 'Resend Email Verification For Domain That Does Not Need It - Throws Exception' => sub {
    my $domain        = create_domain();
    my $mocked_verification_status = Test::MockModule->new('WWW::LogicBoxes');
    $mocked_verification_status->mock(
        'verification_status',
        sub {
            return 'Verified';
        }
    );
    throws_ok {
        $logic_boxes->resend_verification_email( id => $domain->id );
    }
    qr/Domain already verified/;
    $mocked_verification_status->unmock('verification_status');
};

subtest 'Resend Email Verification For Domain Requiring Verification - Successful' => sub {
    my $domain = create_domain();

    my $response;
    lives_ok {
        $response = $logic_boxes->resend_verification_email( id => $domain->id );
    } 'Lives through resend request';
};

done_testing;
