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

my $logic_boxes = create_api;

subtest 'Resend Email Verification For Domain That Does Not Exist - Throws Exception' => sub {
    throws_ok {
        $logic_boxes->resend_verification_email( id => 999999999 );
    }
    qr/No such domain/;
};

subtest 'Resend Email Verification For Domain That Does Not Need It - Throws Exception' => sub {
    my $domain        = create_domain();
    my $mocked_submit = Test::MockModule->new('WWW::LogicBoxes::Role::Command::Domain');
    $mocked_submit->mock(
        'verification_status',
        sub {
            return 'Verified';
        }
    );
    throws_ok {
        $logic_boxes->resend_verification_email( id => $domain->id );
    }
    qr/Domain already verified/;
    $mocked_submit->unmock('submit');
};

subtest 'Resend Email Verification For Domain Requiring Verification - Successful' => sub {
    my $domain = create_domain();

    my $response;
    lives_ok {
        $response = $logic_boxes->resend_verification_email( id => $domain->id );
    } 'Lives through resend request';
    ok( $response, 'Responded with True' );
};

done_testing;
