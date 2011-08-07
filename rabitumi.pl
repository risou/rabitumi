#!/usr/bin/env perl5

use strict;
use warnings;
use utf8;
use Net::Twitter;
use Encode;
use URI::Escape;
use LWP::Simple;
use JSON;
use Config::Pit;

my $account = shift;

my $conf = pit_get($account,
	requires => {
		consumer_key => "consumer_key",
		consumer_secret => "consumer_secret",
		token => "token",
		token_secret => "token_secret",
		home_dir => "home_dir",
		account_id => "account_id",
		word => "word",
	}
);

my $account_id = $conf->{account_id};
my $word = $conf->{word};
my $home = $conf->{home_dir};

my $tw = Net::Twitter->new(
	traits				=> [qw/OAuth API::REST/],
	consumer_key		=> $conf->{consumer_key},
	consumer_secret		=> $conf->{consumer_secret},
	access_token		=> $conf->{token},
	access_token_secret	=> $conf->{token_secret},
);

my $search_api = 'http://search.twitter.com/search.json';

my $log_file = "$home/searched_" . $account . ".log";
check_datafile($log_file);
my ($old_id, $tumi_count) = get_data($log_file);

my $json_text = keyword_search($word);

my $results = $json_text->{results};
my $max_id = $json_text->{max_id};

foreach my $result (reverse @$results) {
	my $text = encode_utf8($result->{text});
	next if $text =~ /RT/;

	my $user_id = $result->{from_user_id_str};
	next if $user_id eq $account_id;

	my $id = $result->{id};
	next if $id <= $old_id;

	print "old_id $old_id", "\n";
	print "id     $id", "\n";
	print "tumi_count $tumi_count", "\n";
	$tumi_count++;
	$tw->retweet($id);
	my $str = "$tumi_count 回目の $word です。";
	$tw->update(decode_utf8($str));
}

set_data($log_file, $max_id, $tumi_count);

sub keyword_search {
	my $keyword = shift;
	my $enced_keyword = uri_escape_utf8($keyword);
	my $json = get($search_api . '?show_user=true&q=' . $enced_keyword);
	return decode_json($json);
}

sub get_data {
	my $log_file = shift;
	my ($old_id, $tumi_count);
	open(IN, $log_file);
	my @in = <IN>;
	if ($in[0]) {
		chomp $in[0];
		$old_id = $in[0];
	}
	if ($in[1]) {
		chomp $in[1];
		$tumi_count = $in[1];
	}
	close(IN);
	return $old_id, $tumi_count;
}

sub check_datafile {
	my $log_file = shift;
	if (!-e $log_file) {
		open(OUT, "> $log_file");
		close(OUT);
	}
}

sub set_data {
	my $log_file = shift;
	my $max_id = shift;
	my $tumi_count = shift;
	open(OUT, ">$log_file");
	print OUT $max_id, "\n";
	print OUT $tumi_count, "\n";
	close(OUT);
}
