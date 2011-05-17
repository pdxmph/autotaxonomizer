# Autotaxonomizer (Non-Summarized Version)

A simple script that reads in a spreadsheet of categories and their associated keywords and classifies the content it finds by checking hed, dek and body for occurrences of the keywords.

If an article is deemed unclassifiable, the script logs it and then passes it through the summarize gem to look for interesting words, which are placed in a frequency table for further refinement of the keyword list.

## Setup

We need a few gems:

`gem install spreadsheet`  
`gem install sanitize`  
`gem install ruby-readability`  
`gem install progress_bar`  


Some variables up front:

* test -- this will limit the output to _n_ articles
* site_abbreviation -- the script will look for this as the first part of files it imports and use it to prefix the name of the spreadsheet it exports
* stop_words -- an array of words we don't want to look for when checking for interesting words

You need an input spreadsheet set up as columns of categories (the first row) and keywords (each row after the first in a column). 

The column heads should be the directory the content is being sorted into (e.g. "/security-tools" and not "Tools")

Name the mapping file `#{site_abbreviation}_mappings.xls` 

You also need the spreadsheet containing the articles. The script looks for the following values in these columns:

* article id: column a
* title: column b
* deck: column c
* current CDEV paths: column d
* page number: column e
* article text: column f

Name the article file `#{site_abbreviation}_articles.xls`. 

Both the article file and mapping file should go in the same directory as the script.

## Run

Run the script. When it's done, look for `#{site_prefix}_remapped_articles.xls` in the directory.

The spreadsheet should have four tabs:

* Mappings: The list of articles with up to three mapped categories for each
* No Hits: Articles that didn't have any keywords from any category
* Candidates: A list of potentially interesting words from articles in the No Hits list
* CATT Mappings: The official CATT migration format 

Use the "Candidates" tab to refine the keywords and re-run the script. 