#! /usr/bin/env ruby
#
# Generates an HTML page to preview one's snippets before submitting.
#
# Performs "{{" and "}}" redaction, and filters the snippets through Markdown,
# even if no Markdown markup is employed. Creates a preview file in the
# current directory, the local URL to which is printed to standard output.
#
# The files from a normal run and a --redact run can be diff'd to check
# redaction differences.
#
# Author: Mike Bland (michael.bland@gsa.gov)
# Date:   2014-12-08
# Source: https://github.com/mbland/mbland-18f-utils

require 'optparse'
require 'redcarpet'
require 'weekly_snippets/publisher'

options = {}
snippets = ''

begin
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [--redact] [input file]"

    opts.on('-r', '--redact', 'Redact spans enclosed by "{{" and "}}"') do |t|
      options[:redact] = t
    end

    opts.on_tail('-h', '--help', "Show this help") do
      puts opts
      exit
    end
  end
  opt_parser.parse!

  if ARGV.length < 1
    puts 'No input file specified'
    exit 1
  elsif ARGV.length != 1
    puts 'Too many arguments'
    exit 1
  end
  infile = open(ARGV[0], 'rb')
  snippets = infile.read
  infile.close

rescue SystemExit
  raise

rescue Exception => e
  puts e
  exit 1
end

last_week = []
this_week = []
current = last_week

snippets.each_line do |line|
  next if line =~ /[Ll]ast [Ww]eek.?$/
  if line =~ /[Tt]his [Ww]eek.?$/
    current = this_week 
    next
  end
  current << line
end

publisher = ::WeeklySnippets::Publisher.new(
  headline: "\n###", public_mode: options[:redact])
snippets = publisher.publish({
  'today' => [
    {'username' => 'unused',
     'timestamp' => 'unused',
     'last-week' => last_week.join,
     'this-week' => this_week.join,
     'public' => true,
     'markdown' => true,
    },
]})['today'][0]

title = "Snippet Preview#{" With Redactions" if options[:redact]}"
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
output_path = File.join(Dir.pwd, 'snippet-preview')
output_path = "#{output_path}#{'-redacted' if options[:redact]}.html"
outfile = open(output_path, 'wb')

outfile.write "<html><head><title>#{title}</title></head>\n"
outfile.write "<body><h1>#{title}</h1>\n"
outfile.write "<h2>Last week</h2>\n"
outfile.write markdown.render(snippets['last-week'])
outfile.write "<h2>This week</h2>\n"
outfile.write markdown.render(snippets['this-week'])
outfile.write "\n</body></html>"
outfile.close
puts "file://#{output_path}"
