require 'uri'
require 'open-uri'

def trip(barcode_base, steps=500)   # (1) 

  steps.times do         # (2)  
    prng = Random.new
	bcd = make_berlin_barcode barcode_base
    barcode_base += prng.rand(10)
	hs_url = url_for_berlin(bcd)
    puts hs_url
    #page = fetch(hs_url)
	#puts page
    #image_link = scrape_image_link(page)
	#puts page
	#puts image_link
	#if image_link != ""
    fetch_image(hs_url, bcd)
	#end
  end
end


def make_berlin_barcode(num)
  "B_10_" + "%07d" % num
end


### Fetching image pages from kew
def url_for_berlin(barcode)
  #01234567890 
  #B_10_0002471.jpg
  str_path = barcode[0,1] + "/" +barcode[2,2] + "/" + barcode[5,2] + "/" + barcode[7,2] + "/" + barcode[9,2] 
  "http://ww2.bgbm.org/herbarium/images/#{str_path}/#{barcode}.jpg"
end

def fetch(url)
  open(url) { | response |
    response.read
  }
end

def fetch_image(img_link,barcode)
  begin
    open(img_link) {|f|
      File.open("C:\\Sites\\test_download\\images\\#{barcode}.jpg","wb") do |file|	  
	    IO.copy_stream(f, file)
      end
    }
  rescue OpenURI::HTTPError => error
	puts error.io.status
  end
end

def scrape_image_link(html)
  re_start = /<span itemprop=\"image\" style=\"display: none;\">/
  re_stop  = /<\/span>/
  img_element = restrict(html, re_start, re_stop)
  img_element
end

def restrict(html, start_regexp, stop_regexp)
  start = html.index(start_regexp)
  ret = ""
  if !start.nil?
    stop = html.index(stop_regexp, start)
    ret = html[start..stop-1]
    ret.slice!(start_regexp)
    ret.slice!(stop_regexp)
  end
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