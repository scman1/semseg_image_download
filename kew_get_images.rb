require 'uri'
require 'open-uri'

def trip(barcode_base, steps=495)   # (1) 

  steps.times do         # (2)  
    prng = Random.new
	bcd = make_rbgk_barcode barcode_base
    barcode_base += prng.rand(10)
	hs_url = url_for_rbgk(bcd)
    puts hs_url
    page = fetch(hs_url)
	#puts page
    image_link = scrape_image_link(page)
	#puts page
	puts image_link
	fetch_image(image_link, bcd)
  end
end


def make_rbgk_barcode(num)
  "K" + "%09d" % num
end


### Fetching image pages from kew
def url_for_rbgk(barcode)
  "http://apps.kew.org/herbcat/getImage.do?imageBarcode=" + barcode
end

def fetch(url)
  open(url) { | response |
    response.read
  }
end

def fetch_image(img_link,barcode)
  open(img_link) {|f|
    File.open("C:\\Sites\\test_download\\images\\#{barcode}.jpg","wb") do |file|
	  IO.copy_stream(f, file)
    end
  }
end

def scrape_image_link(html)
  re_start = /<p><a href=\"/
  re_stop  = /\">View full-size image<\/a><\/p>/
  img_element = restrict(html, re_start, re_stop)
  img_element
end

def restrict(html, start_regexp, stop_regexp)
  start = html.index(start_regexp)
  stop = html.index(stop_regexp)
  ret = html[start..stop-1]
  ret.slice!(start_regexp)
  ret.slice!(stop_regexp)
  ret
end

if $0 == __FILE__

  if ARGV[0] == '--csv'
    FORMAT_STYLE = :csv_string
    ARGV.shift
  else
    FORMAT_STYLE = :normal_string
  end
    
  starting = ARGV[0].to_i || 640051
  trip(starting)
end