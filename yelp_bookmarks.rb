require 'rubygems'
require 'oauth'
require 'watir'
require 'watir-webdriver'
require 'headless'
require 'open-uri'
require 'json'

$consumer_key = 'JSv4y-8WJtkfhnd2VpICjg'
$consumer_secret = '7BXXrtHY9PNQnuDVxgZxoi6qH3g'
$token = 'ktBT5u0jQm1qUnjYO3U08KskjEBIW9P0'
$token_secret = '7bkQ7qnVEQ-zAojqaMgWM4USQDM'

$api_host = 'api.yelp.com'

$city = "San Francisco"
$state = "California"

$sample = {"region"=>{"span"=>{"latitude_delta"=>0.0, "longitude_delta"=>0.0}, "center"=>{"latitude"=>37.7954406258333, "longitude"=>-122.393188476562}}, "total"=>1, "businesses"=>[{"is_claimed"=>true, "rating"=>4.5, "mobile_url"=>"http://m.yelp.com/biz/frog-hollow-farm-market-and-cafe-san-francisco", "rating_img_url"=>"http://s3-media2.fl.yelpcdn.com/assets/2/www/img/99493c12711e/ico/stars/v1/stars_4_half.png", "review_count"=>205, "name"=>"Frog Hollow Farm Market & Cafe", "snippet_image_url"=>"http://s3-media4.fl.yelpcdn.com/photo/Z7I-dpj7gbAP_t78hTH_GQ/ms.jpg", "rating_img_url_small"=>"http://s3-media2.fl.yelpcdn.com/assets/2/www/img/a5221e66bc70/ico/stars/v1/stars_small_4_half.png", "url"=>"http://www.yelp.com/biz/frog-hollow-farm-market-and-cafe-san-francisco", "phone"=>"4154450990", "snippet_text"=>"Two words: AVOCADO TOAST.\n\n+$2 to add a side seasonal salad.\n\nDROOL.", "image_url"=>"http://s3-media2.fl.yelpcdn.com/bphoto/1Q9Hwwg9mMAS6uW26R4WzQ/ms.jpg", "categories"=>[["Bakeries", "bakeries"], ["Coffee & Tea", "coffee"], ["Fruits & Veggies", "markets"]], "display_phone"=>"+1-415-445-0990", "rating_img_url_large"=>"http://s3-media4.fl.yelpcdn.com/assets/2/www/img/9f83790ff7f6/ico/stars/v1/stars_large_4_half.png", "id"=>"frog-hollow-farm-market-and-cafe-san-francisco", "is_closed"=>false, "location"=>{"city"=>"San Francisco", "display_address"=>["1 Ferry Bldg", "Ste 46", "Embarcadero", "San Francisco, CA 94111"], "geo_accuracy"=>9, "neighborhoods"=>["Embarcadero", "SoMa", "South Beach"], "postal_code"=>"94111", "country_code"=>"US", "address"=>["1 Ferry Bldg", "Ste 46"], "coordinate"=>{"latitude"=>37.7954406258333, "longitude"=>-122.393188476562}, "state_code"=>"CA"}}]}

$yelp_username = "neelk07@gmail.com"
$yelp_password = "13121993"


def yelp(place)
	#consumer = OAuth::Consumer.new($consumer_key, $consumer_secret, {:site => "http://#{$api_host}"})
	#access_token = OAuth::AccessToken.new(consumer, $token, $token_secret)
	#path = "/v2/search?term=" + place + "&location=" + $city + "&limit=1&sort=0"
	#path = URI::encode(path)
	#p JSON::parse(access_token.get(path).body)
	headless = Headless.new
	headless.start
	browser = yelp_login()
	business_url = $sample['businesses'][0]['url']
	browser.goto(business_url)
	browser.link(:class => 'ybtn ybtn-small ytype js-bookmark-button not-bookmarked').click
	#
	browser.text_field(:name, "note")
	browser.button(:class => 'ybtn ybtn-primary ybtn-small').click
	puts "Working on: " + $sample['businesses'][0]['name'] + "....."
	headless.destroy
rescue => msg
	puts msg
end


def yelp_login()
	browser = Watir::Browser.start("http://yelp.com")
	browser.link(:class => "log-in").click
	browser.text_field(:name => 'email').set $yelp_username
	browser.text_field(:name => 'password').set $yelp_password
	browser.button(:name => 'action_submit').click
	return browser
end
	

def read_from_file(filename)
	file = File.new(filename + ".txt", "r")
	while line = file.gets
		poi_name = retrieve_places(line)
		if poi_name != nil
			yelp(poi_name) 
			return
		end
	end
	file.close
end

def retrieve_places(line)
	place = line.split(':').first
	if place.split(' ').first == '*'
		return place.delete! '*'
	else
		return nil
	end
end

read_from_file("food")