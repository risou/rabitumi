#!/usr/bin/env perl5

use strict;
use warnings;
use utf8;
use Net::Twitter;
use Config::Pit;
use Encode;
use URI::Escape;
use LWP::Simple;

my $consumer_key = '';
my $consumer_secret = '';
my $token = '';
my $token_secret = '';

my $tw = Net::Twitter->new(
	traits				=> [qw/OAuth API::REST/],
	consumer_key		=> $consumer_key,
	consumer_secret		=> $consumer_secret,
	access_token		=> $token,
	access_token_secret	=> $token_secret,
);

my $api = 'http://search.twitter.com/search.json';

my $word = '#rabisuketumibukai';
my $enced_word = uri_escape_utf8($word);

my $json = get($api . '?show_user=true&q=' . $enced_word);

print $json;
