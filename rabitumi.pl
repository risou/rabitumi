#!/usr/bin/env perl5

use strict;
use warnings;
use utf8;
use Net::Twitter;
use Encode;
use URI::Escape;
use LWP::Simple;
use JSON;

my $consumer_key = '';
my $consumer_secret = '';
my $token = '';
my $token_secret = '';

my $home = '';

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

my $log_file = "$home/searched.log";
if (!-e $log_file) {
	open(OUT, "> $log_file");
	close(OUT);
}

my $old_id = 0;
my $tumi_count = 0;
open(IN, $log_file);
my @in = <IN>;
if ($in[0]) {
	print "in[0] $in[0]\n";
	chomp $in[0];
	$old_id = $in[0];
}
if ($in[1]) {
	print "in[1] $in[1]\n";
	chomp $in[1];
	$tumi_count = $in[1];
}
close(IN);

my $json_text = decode_json($json);
my $results = $json_text->{results};
my $max_id = $json_text->{max_id};
print "\nmax_id $max_id", "\n";
foreach my $result (reverse @$results) {
	my $text = encode_utf8($result->{text});
	next if $text =~ /^RT/;

	my $user_id = $result->{from_user_id_str};
	next if $user_id eq '377731160';

	my $id = $result->{id};
	next if $id <= $old_id;

	print "old_id $old_id", "\n";
	print "id     $id", "\n";
	print "tumi_count $tumi_count", "\n";
	$tumi_count++;
	$tw->retweet($id);
	my $str = "$tumi_count 回目の #rabisuketumibukai です。";
	$tw->update(decode_utf8($str));
}

print "$log_file $max_id $tumi_count\n";
open(OUT, "> $log_file");
print OUT $max_id, "\n";
print OUT $tumi_count, "\n";
close(OUT);

