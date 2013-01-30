#!/usr/bin/env ruby

require 'mechanize'
require 'optparse'
require './config.rb'


# Setting up the Command line arguments
options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: send.rb [options]"

  opts.on("-r", "--recipient", :REQUIRED, "Recipient's phone number") do |v|
    options[:recipient] = v
  end
  
  opts.on("-m", "--message", :REQUIRED, "Message") do |v|
    options[:message]   = v
  end

  opts.on( '-h', '--help', 'Display this screen.' ) do
    puts opts
    exit
  end

end

optparse.parse!

if options[:message].nil? or options[:recipient].nil? 
  p optparse
  exit
end

# Receipient number and message
recipient = options[:recipient]
message   = options[:message]

# Setup Mechanize
agent = Mechanize.new
agent.user_agent_alias = 'Linux Firefox'

# Get the index page, cookies
page = agent.get("http://www.way2sms.com")
page.form.action = './content/prehome.jsp'
page = page.form.submit


# Get the login page
host = page.uri.to_s[/.*way2sms.com/]
url = page.uri.to_s.sub("prehome.jsp","index.html")
page = agent.get(url)

# Submit the username/password
form = page.forms[0]
form['username'] = PHONENUMBER
form['password'] = PASSWORD
form.action = '../Login1.action'
page = agent.submit(form, form.buttons[1])

# Get the token
token = page.parser.at_xpath('//input[@id="Token"]')['value']

# Send SMS URL
url  = host + "/jsp/InstantSMS.jsp?Token=" + token
page = agent.get(url)

# Enter the message and send
form = page.forms[0]
form['MobNo']    = recipient
form['textArea'] = message
page = form.submit

# Status 
message = page.uri.to_s[/(?<=SentMessage=).*?&/].gsub(/[&+]/," ")
puts message
