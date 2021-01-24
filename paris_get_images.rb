require 'uri'
require 'open-uri'
#solve error
# https://superdevresources.com/ssl-error-ruby-gems-windows/
# download ssl cert file
# save it to rails installer dir
# add it to environment variables
# set SSL_CERT_FILE=C:\RailsInstaller\cacert.pem

def trip(barcode_base, steps=5000)   # (1) 

  steps.times do         # (2)  
    prng = Random.new
	bcd = make_mnhn_barcode barcode_base
    barcode_base += 1#prng.rand(10)
	hs_url = url_for_mnhn(bcd)
    puts hs_url
    page = fetch(hs_url)
	if !page.nil?
      image_link = scrape_image_link(page)
	  puts image_link
	  if image_link != ""
        fetch_image(image_link, bcd)
	  end
	end
  end
end


def make_mnhn_barcode(num)
  "m" + "%05d" % num
end


### Fetching image pages from kew
def url_for_mnhn(barcode)
  #"https://science.mnhn.fr/institution/mnhn/collection/p/item/" + barcode #herbarium sheets
  "https://science.mnhn.fr/institution/mnhn/collection/f/item/" + barcode #fossil slides
end

def fetch(url)
  begin
    open(url) { | response |
      response.read
    }
  rescue OpenURI::HTTPError => error
    puts "ERROR:" + error.io.status[0] + " " +error.io.status[1]
  end
end

def fetch_image(img_link,barcode)
  begin
    open(img_link) {|f|
      File.open("C:\\Sites\\test_download\\images\\#{barcode}.jpg","wb") do |file|
	    IO.copy_stream(f, file)
      end
    }
  rescue OpenURI::HTTPError => error
    puts error.io.status[0] + error.io.status[1]
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
    
  starting = ARGV[0].to_i || 80101
  trip(starting)
end