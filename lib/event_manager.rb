# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

template_letter = File.read 'form_letter.erb'
erb_template = ERB.new template_letter

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting a website'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exists? 'output'

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone_number)
  phone_array = phone_number.to_s.split('').keep_if { |char| char.between?('0', '9')}
  case phone_array.length
  when 10
    phone_array.join('')
  when 11
    phone_array.length[0] == 1 ? phone_array[1..10].join('') : 'Bad number'
  else
    'Bad number'
  end
end

def most_occuring(array)
  count = array.tally
  highest_value = 0
  count.each_value { |value| highest_value = value if value > highest_value }
  count.keep_if { |key, value| value == highest_value}.keys
end

puts 'EventManager Initialize!'
hours = []
days_of_week = []

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone])
  date = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M')

  hours.push date.hour
  days_of_week.push Date::DAYNAMES[date.wday]
  #zipcode = clean_zipcode(row[:zipcode])
  #legislators = legislators_by_zipcode(zipcode)
  #form_letter = erb_template.result(binding)
  #save_thank_you_letter(id, form_letter)
end

puts "Most Active Hours: #{most_occuring(hours)}"
puts "Most Active Days: #{most_occuring(days_of_week)}"

