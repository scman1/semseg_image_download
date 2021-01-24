require 'uri'
require 'open-uri'

def trip(barcode_base, steps=50)   # (1) 

  steps.times do         # (2)  
    prng = Random.new
	bcd = make_naturalis_barcode barcode_base
    barcode_base += prng.rand(10)
	hs_url = url_for_naturalis(bcd)
    puts hs_url
	fetch_image(hs_url, bcd)
  end
end


def make_naturalis_barcode(num)
  #"AMD." + "%06d" % num # Herbarium sheets
  "L." + "%07d" % num # Slides Botany
  "ZMA.INS."+"%06d" % num # Slides Invertebrate
end


### Fetching image pages from kew
def url_for_naturalis(barcode)
  "http://medialib.naturalis.nl/file/id/#{barcode}/format/master"
end

def fetch(url)
  open(url) { | response |
    response.read
  }
end

def fetch_image(img_link,barcode)
  open(img_link) {|f|
    #File.open("C:\\Sites\\test_download\\images\\#{barcode}.jpg","wb") do |file|
    File.open("#{barcode}.jpg","wb") do |file|
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
    
  starting = ARGV[0].to_i || 100007
  trip(starting)
end