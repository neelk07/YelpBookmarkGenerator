require 'rubygems'
require 'oauth'
require 'watir'
require 'watir-webdriver'
require 'headless'
require 'open-uri'
require 'json'


$api_host = 'api.yelp.com'

$city = "San Francisco"
$state = "California"



def yelp(place, comment, browser)
	consumer = OAuth::Consumer.new($consumer_key, $consumer_secret, {:site => "http://#{$api_host}"})
	access_token = OAuth::AccessToken.new(consumer, $token, $token_secret)
	path = "/v2/search?term=" + place + "&location=" + $city + "&limit=1&sort=0"
	path = URI::encode(path)
	$sample = JSON::parse(access_token.get(path).body)
	business_url = $sample['businesses'][0]['url']
	browser.goto(business_url)
	browser.link(:class => 'ybtn ybtn-small ytype js-bookmark-button not-bookmarked').click
	browser.textarea(:id, "bookmark-popup-note").wait_until_present.set(comment)
	browser.button(:class => 'ybtn ybtn-primary ybtn-small').click
	puts "Working on: " + $sample['businesses'][0]['name'] + "....."
rescue => msg
	puts msg
end


def yelp_login(browser)
	browser.link(:class => "log-in").click
	browser.text_field(:name => 'email').set $yelp_username
	browser.text_field(:name => 'password').set $yelp_password
	sleep(5)
	browser.button(:name => 'action_submit').click
end


def read_from_file(filename)
	headless = Headless.new
	headless.start
	browser = Watir::Browser.start("http://yelp.com")
	yelp_login(browser)
	file = File.new(filename + ".txt", "r")
	while line = file.gets
		info = retrieve_places(line)
		if info != nil
			poi_name = info['place']
			poi_comment = info['comment']
			yelp(poi_name, poi_comment, browser)
			#return
		end
	end
	file.close
	headless.destroy
end

def retrieve_places(line)
	separated = line.split(':')
	place = separated.first
	separated.delete_if{ |c| c == " " or c.length < 5}
	comment = separated.last
	if place.split(' ').first == '*'
		place = place.delete! '*'
		info = { "place" => place, "comment" => comment }
		return info
	else
		return nil
	end
end

read_from_file("food")
