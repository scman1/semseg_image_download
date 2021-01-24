require 'uri'
require 'open-uri'
require 'csv'

def trip(records_file)   # (1) 

  read_from = Dir.pwd+"/"+records_file
  #read csv file 
  csv_text = File.read(read_from)
  csv_data = CSV.parse(csv_text, :headers => true)
  csv_data.each do |row|
    bcd = row[2] 
	image_link = row [5]
	puts bcd + ": " + image_link
	if image_link != ""
      fetch_image(image_link, bcd)
	end	
  end
end


def make_mnhn_barcode(num)
  "p" + "%08d" % num
end


### Fetching image pages from kew
def url_for_mnhn(barcode)
  "https://science.mnhn.fr/institution/mnhn/collection/p/item/" + barcode
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
  #<img src="http://www.nhm.ac.uk/services/media-store/asset/270705ab333a65db2573eeda2836c915c47a9621/contents/preview" alt="BM000554017" />
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
    
  starting = ARGV[0] || nhm_multimedia
  trip(starting)
end