# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

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

puts 'EventManager Initialize!'

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone])
  #zipcode = clean_zipcode(row[:zipcode])
  #legislators = legislators_by_zipcode(zipcode)
  #form_letter = erb_template.result(binding)
  #save_thank_you_letter(id, form_letter)
  puts "#{name} #{phone_number}"
end
