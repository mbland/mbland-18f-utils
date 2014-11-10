#! /usr/bin/env ruby
#
# Parses snippets in CSV format into plaintext or HTML.
#
# For now depends upon the already-downloaded CSV file being specified on the
# command line. May be extended to download the CSV directly from a URL in the
# future.
#
# Author: Mike Bland (michael.bland@gsa.gov)
# Date:   2014-11-10
# Source: https://github.com/mbland/mbland-18f-utils

require 'CSV'
require 'optparse'

options = {}

begin
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options] [input file]"

    opts.on('-t', '--text', "Print as plaintext") do |t|
      options[:text] = t
    end

    opts.on('--html', "Print as html") do |h|
      options[:html] = h
    end

    opts.on_tail('-h', '--help', "Show this help") do
      puts opts
      exit
    end
  end
  opt_parser.parse!

  if options[:text] and options[:html]
    raise ArgumentError, 'Only one of --text or --html can be specified'
  elsif not (options[:text] or options[:html])
    raise ArgumentError, 'One of --text or --html must be specified'
  end

  if ARGV.length < 1
    puts 'No input file specified'
    args_fail = true
  elsif ARGV.length != 1
    puts 'Too many arguments'
    args_fail = true
  end
  infile = open(ARGV[0], 'r')

rescue SystemExit
  raise

rescue Exception => e
  puts e
  exit 1
end

csv = CSV.new(infile, :headers => true, :header_converters => :symbol)

def snippets_to_text(csv)
  csv.to_a.map do |row|
    r = row.to_hash
    name = r[:name]
    print "#{name}\n#{'-' * name.length}\n#{r[:snippets]}\n\n"
  end
end

def snippets_to_html(csv)
  csv.to_a.map do |r|
    print "<h2 class='snippet'>#{r[:name]}</h2>\n"
    print "<pre class='snippet'>#{r[:snippets]}</pre>\n\n"
  end
end

if options[:text]
  snippets_to_text csv
elsif options[:html]
  snippets_to_html csv
else
  raise "This should be unreachable."
end
