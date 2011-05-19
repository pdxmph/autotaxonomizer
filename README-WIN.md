# Setting Up a Ruby Environment On Windows (non-summarizing autotaxonomizer)

To get the autotaxonomizer running on Windows, you need to get a working Ruby environment first. Since I haven't had any luck getting libots working with Ruby on Windows, the autotaxonomizer's recommendations feature won't work, so there's no need to install the `summarize` gem.

The Ruby distributed by [RubyInstaller.org](http://rubyinstaller.org) works for our purposes. We also want the Ruby Development Kit, both available here:

<http://rubyinstaller.org/downloads/>

This is tested on Ruby 1.8.7.


## 1. install rubyinstaller package (rubyinstaller-1.8.7-p334.exe)

- accept the license
- accept the default path, tick "add Ruby executables" and "Associate .rb and .rbw files ..."

This will place Ruby in your Start/All Programs menu under "Ruby 1.8.7-p334"

- launch Ruby from the Start Menu to open a command prompt with the proper Ruby environment running. You can confirm it's up and running by entering the command:

`ruby -v`

## 2. Update your system Gems by entering the command:

`gem update --system`

You'll get a lot of warnings, but it should eventually finish with:

`RubyGems system software updated`


## 3. Install the Ruby Devkit:

Extract the DevKit archive to a directory you can easily navigate to (e.g. `c:\ruby_devkit`)

At the command prompt, cd to the devkit directory and enter this command:

`ruby dk.rb init`

It should list your Ruby installation with a message like:

`[Info] Found RubyInstaller v1.8.7 at c:/ruby187`

You can confirm that the devkit is properly installed and running by trying to install a Gem that requires Windows-specific compilation during installation:

`gem install rdiscount --platform=ruby`

## 4. Install the Gems you need to run the autotaxonomizer:

`gem install spreadsheet`  
`gem install sanitize`  
`gem install ruby-readability`  
`gem install progress_bar`  


## 5. Using the autotaxonomizer:

- To do a simple "make sure it runs at all" test, create a directory to keep the script and all the setup spreadsheets in one place. 

- Edit the autotaxonomizer.rb script to do a short run:  Line 16 has a variable currently set to "test = 0". Set test to a small value (100 or 200).

- Check the site abbreviation variable (line 20) and make sure you have the needed mapping and article spreadsheets in the current directory, with the correct names. 

- Once you've made sure it's set up correctly, save it and run it with:

`ruby autotaxonomizer.rb`

Once it's done running, check the directory for a spreadsheet with a name that begins with your site abbreviation and ends in "_remapped_articles.xls"

It should have three tabs:

mappings, misses and CATT mappings

