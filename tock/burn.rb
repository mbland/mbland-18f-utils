#! /usr/bin/env ruby
# Author: Mike Bland <michael.bland@gsa.gov>

DATES=%w(2015-03-30
  2015-04-05
  2015-04-12
  2015-04-19
  2015-04-26
  2015-05-03
  2015-05-10
  2015-05-17
  2015-05-24
  2015-05-31)

PROJECTS=["18F Hub", "18F Guides", "18F EDU", "USDS Hub"]

TICK=File.join File.dirname(__FILE__), 'tick.rb'

abort unless system TICK, DATES.join(','), PROJECTS.join(',')
