#!/usr/bin/ruby

=begin
 auto taxonomizer v 0.2
 See README.md for required libraries and setup instructions
 
 If the summarize gem is too much of a hassle to build, check out the unsummarized branch, which has less fussy dependencies

=end

require "rubygems"
require "spreadsheet"
require "sanitize"
require "readability"
require "progress_bar"
require "summarize"

# set this to some value greater than 0 to limit output to n rows
test = 50

# to prefix the output (e.g. 'esp' for 'eSecurityPlanet')
site_abbreviation = "sbc"

# set up a filter path to only gather articles from a given container, set to "unfiltered" to pull in everything

filter_path = "unfiltered"

# output filename
output_filename = File.dirname(__FILE__) + "/#{site_abbreviation}_remapped_articles.xls"

# to designate Old Site
old_site = "http://www.smallbusinesscomputing.com"

# to designate CE site
ce_site = "http://www.smallbusinesscomputing.com"

# array of words we don't want to count or find
stop_words = []

# the spreadsheets we'll read, name these using the "site_abbreviation" variable 

article_spreadsheet = File.dirname(__FILE__) + "/#{site_abbreviation}_articles.xls"
mapping_spreadsheet = File.dirname(__FILE__) + "/#{site_abbreviation}_mappings.xls"

# read keyword/container mappings here
keyword_book = Spreadsheet.open(mapping_spreadsheet)
keyword_sheet = keyword_book.worksheet 0

# read in article data from here
article_book = Spreadsheet.open(article_spreadsheet)
article_sheet = article_book.worksheet 0

# set up the progress bar 
if test > 0
  progress_length = test
else
  progress_length = article_sheet.dimensions[1] # get the number of filled rows
end

bar = ProgressBar.new(progress_length)

# store output here
output_book = Spreadsheet::Workbook.new
output_sheet = output_book.create_worksheet :name => "Mappings"

# log articles that don't have any hits
nohit_sheet = output_book.create_worksheet :name => "No Hits"
freq_table_sheet = output_book.create_worksheet :name => "Candidates"

# set up the title row for the output sheet
output_sheet.row(0).concat ["CDEV ID","Title","Mapped Container 1","Mapped Container 2","Mapped Container 3"]

# CATT remapping sheet
catt_sheet = output_book.create_worksheet :name => "CATT mappings"

catt_sheet.row(0).concat ["CDEV ID","Old Site / Directory","CE Site","CE Container"]

# create the hash we'll use to store each category and its keywords
categories = {}

# hashes don't come back ordered, so we want to go through the categories in the order
# they're defined in the spreadsheet and put them in an array, which does come back
# in order

cats = []

keyword_sheet.row(0).each do |c|
  cats << c
end

col = 0

while col < cats.length

  current_row = 0
  key = ""

  keyword_sheet.column(col).each do |row|

    break if row == nil

    # cells in the first row will become the key for our hash
    if current_row == 0
      key = row
      categories[row] = Array.new

      # the contents of cells in the rows after the first are added to the array that constitutes the
      # value of the key/value pairs in the hash
    else
      categories[key] << row
    end
    current_row +=1
  end
  col += 1
end

freq_table = Hash.new(0)

output_row = 1
nohit_row = 0
catt_sheet_row = 1


article_sheet.each 1 do |row|

  # might want to test, so let's make it easy to kill output before a complete run:

  if test > 0
    break if output_row > test
  end

  # we want to keep track of the number of categories we've found and stop at 3
  hits = 0

  # weed out additional pages past the first from the article list I was given
  next if row[4] > 1

  # downcasing the title, deck and body will make this easier
  cdev_id = row[0].to_i
  title = row[1].to_s.downcase
  deck = row[2].to_s.downcase

  # the dump has each directory ("path") the article is currently found in
  paths = row[3].split(",")

  # clean out the whitespace
  paths.each {|p| p.strip! }

  next unless paths.include?(filter_path) || filter_path == "unfiltered"



  #  puts title

  # sanitize the markup in the body
  cleaned_text = Sanitize.clean(Readability::Document.new(row[5]).content)

  # get some summary word candidates
  raw_topics = cleaned_text.summarize(:topics => true)[1]
  possible_topics = raw_topics.split(",")

  # clean out our stopwords list
  stop_words.each do |sw|
    possible_topics.delete(sw)
  end

  # just the first 600 characters of the article text
  text = cleaned_text[0..600].downcase

  # put our elements in an array so we can loop through them with just one function
  elements = [title,deck,text]

  output_sheet.row(output_row)[0] = cdev_id
  output_sheet.row(output_row)[1] = title

  # keep track of which categories we have hits for, so we don't repeat them
  hit_cats = []

  # loop through the keys in our hash using the cats array we set up to
  # keep things in order

  cats.each do |cat|

    # look up the array assigned to the key for the category
    keywords = categories[cat]

    # loop through each keyword in the hash's value array
    keywords.each do |kw|
      keyword = kw.to_s.downcase

      elements.each do |e|
        if e.include?(keyword) && !hit_cats.include?(cat) && hit_cats.size < 4
          hits +=1
          hit_cats << cat
          output_sheet.row(output_row)[hits + 1] = cat
        end
      end
    end




  end

  # write out whatever we found in the official CATT format to the catt_sheet

  unless hit_cats.size == 0

    paths.each do |path|
      next unless path == filter_path || filter_path == "unfiltered"
      hit_cats.each do |category|
        catt_sheet.row(catt_sheet_row).concat [cdev_id,"#{old_site}#{path}",ce_site,category]
        catt_sheet_row +=1
      end
    end
  end


  # if we don't find keywords from any categories, the hit counter never goes above 0,
  # in that case, we want to log the non-hit article for review so we can refine the
  # list of keywords

  if hits == 0
    i = 1
    nohit_sheet.row(nohit_row)[0] = title
    nohit_row +=1
    possible_topics.each do |pt|
      freq_table[pt] += 1
    end
  end


  # notch the progress bar by 1
  bar.increment!

  # move on to the next row
  output_row += 1

end



# generate the word candidates tab (sorting the hash of likely keywords)
freq_row = 0

freq_table.sort{|k,v| v[1]<=>k[1]}.each { |elem|
  freq_table_sheet.row(freq_row)[0] = elem[0]
  freq_table_sheet.row(freq_row)[1] = elem[1]
  freq_row +=1
}




# write the spreadsheet
output_book.write output_filename
