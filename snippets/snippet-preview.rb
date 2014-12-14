#! /usr/bin/env ruby
#
# Generates an HTML page to preview one's snippets before submitting.
#
# NOTE: Requires the 'redcarpet' gem.
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

if options[:redact]
  snippets.gsub!(/\{\{.*?\}\}/m,'')
else
  snippets.gsub!(/\{\{/,'')
  snippets.gsub!(/\}\}/,'')
end
snippets.gsub!(/^\n\n+/m, '')

parsed = []

snippets.each_line do |line|
  line.rstrip!

  # Convert headline markers to h4, since the layout uses h3.
  line.sub!(/^(#+)/, '####')

  # Convert Last week/this week markers to h3.
  parsed << "\n" if line.sub!(/([Ll]ast|[Tt]his) [Ww]eek.?$/, '### \0')

  # Add item markers for those who used plaintext and didn't add them.
  line.sub!(/^([A-Za-z0-9])/, '- \1') unless line =~ /week:$/

  # Fixup item markers missing a space.
  line.sub!(/^[-*]([^ ])/, '- \1')

  parsed << line unless line.empty? or line =~ /^[\t ]*$/
end

title = "Snippet Preview#{" With Redactions" if options[:redact]}"
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
output_path = File.join(Dir.pwd, 'snippet-preview')
output_path = "#{output_path}#{'-redacted' if options[:redact]}.html"
outfile = open(output_path, 'wb')

outfile.write "<html><head><title>#{title}</title></head>\n"
outfile.write "<body><h1>#{title}</h1>\n"
outfile.write markdown.render(parsed.join("\n"))
outfile.write "\n</body></html>"
outfile.close
puts "file://#{output_path}"
