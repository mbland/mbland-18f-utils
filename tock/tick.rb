#! /usr/bin/env ruby
# Author: Mike Bland <michael.bland@gsa.gov>

require 'csv'
require 'net/https'
require 'uri'

BASE_URL = 'https://tock.18f.gov/reports/'

if ARGV.size < 2 || ENV['OAUTH_COOKIE'].nil?
  abort [
    "Usage: OAUTH_COOKIE=cookie #{$0} YYYY-MM-DD[,...] project_name[,...]",
    "Multiple dates and project names can be retrieved by providing comma-",
    "separated lists of date stamps and project names."
  ].join("\n")
end

date_stamps, project_names = ARGV
project_names = project_names.split(',')
oauth_cookie = ENV['OAUTH_COOKIE']

date_stamps.split(',').sort.each do |date_stamp|
  uri = URI.parse BASE_URL + "#{date_stamp}.csv/"
  http = Net::HTTP.new uri.host, 443
  http.use_ssl = true
  r = http.get uri.request_uri, {'Cookie' => "_oauthproxy=#{oauth_cookie}"}

  unless r.is_a? Net::HTTPSuccess
    abort "Failed to get data for #{date_stamp}: #{r.message}"
  end

  fields = {}
  project_data = {}
  CSV.parse r.body do |row|
    if fields.empty?
      row.each_index {|i| fields[row[i]] = i}
    else
      project = row[fields['Project']]
      if project_names.include? project
        (project_data[project] ||= []) << {
          :user => row[fields['User']],
          :hours => row[fields['Number of Hours']],
        }
      end
    end
  end

  puts "*** #{date_stamp} ***"
  project_data.each do |project_name,billing|
    puts "  --- #{project_name} ---"
    billing.each {|i| puts "    #{i[:user]} %5.2f" % i[:hours]}
  end
end
