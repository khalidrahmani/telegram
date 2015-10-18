# encoding: utf-8
# +0018188050365

=begin crontab -e
SHELL=/bin/bash
BASH_ENV=/home/yahya/.bash_profile
HOME=/home/yahya
#*/2 * * * * cd ~/Desktop/Aptana_Rails/workspace/ElanceSlackAPI/telegram_project && ruby telegram_api.rb >> ~/IndigoWS/cronlog.log 2>&1
=end

require 'google/api_client'
require 'google_drive'
require 'json'
require 'typhoeus'

#CLIENT_ID          = "833494348776-pme294i5e5bui19d9e3nj3g9mhov6lgj.apps.googleusercontent.com" # KHALID
#CLIENT_SECRET      = "k0CwXlTPOcF18OvUI1FiRNhG"
#REFRESH_TOKEN      = "1/LdkEyZQ5oP9NUQlEU6lgMiFEoGGv9dxCYZGGGfAhvvA"

CLIENT_ID          = "164802303680-vi1hubrkrt488i5oojabhcuiqh989hok.apps.googleusercontent.com"# "190162344807-6mvd0ur33o4erha6m37sd1q8llj6b9rh.apps.googleusercontent.com" # CART
CLIENT_SECRET      = "u3qRD-ilJrljyqI3N7FOOwnP" # "PkBg_mXSQD5j48Be8j-Uq0x9"
REFRESH_TOKEN      = "1/p85GT4PDp-pAwSMFPGjHIUzdoyDBUlBpdCj4FxfLyP4" # "1/NMGRAAjifACkk-52IYAYQBKZ1EUsnI3zYXLai_9QgDbBactUREZofsF9C7PrpE-j" # http://localhost/?code=4/ygM8bHydAZfVRQL9RU76T4KTmX9QB1k2E0rB_CmxTnY#

SHEET_NAME         = "Telegram"

def refresh_token
  data = {
    :client_id =>     CLIENT_ID,
    :client_secret => CLIENT_SECRET,
    :refresh_token => REFRESH_TOKEN,
    :grant_type =>    "refresh_token"
  }
  res = Typhoeus.post("https://accounts.google.com/o/oauth2/token", body: data)
  res = JSON.parse(res.body)
  return res["access_token"]  
end

drive_session   = GoogleDrive.login_with_oauth(refresh_token)
sheet           = drive_session.file_by_title(SHEET_NAME)
worksheet       = sheet.worksheets.last

default_message   = worksheet[2, 4]
multiline_message = worksheet[2, 5].strip.downcase == "yes" # Multi lines message
 
to_process = false
phones     = []

(3..worksheet.num_rows).each do |row|    
    if worksheet[row, 1].strip == "END"
      to_process = true
      break
    end
    next if worksheet[row, 1] == "" or worksheet[row, 2] == "" or worksheet[row, 3] == "" 
    phones.push({phone: "+"+worksheet[row, 1].strip, name: worksheet[row, 3].strip})    
end

messages   = []
if multiline_message == true
  messages = default_message.split("\n")
else
  message   = default_message.gsub("\n","\\n")
  message   = "\" #{message} \""
  messages.push(message)
end

exit if to_process == false

newsheet = sheet.add_worksheet (Date.today + 1).to_s
newsheet[1, 1] = "Phone Number"        
newsheet[1, 2] = "Name"        
newsheet[1, 3] = "User ID"        
newsheet[1, 4] = "Message"        
newsheet[1, 5] = "Multi Lines"        
newsheet[2, 4] = worksheet[2, 4]        
newsheet[2, 5] = worksheet[2, 5]      
newsheet.save

dev_daemon  = File.dirname(__FILE__)+'/../../../../tests/tg/bin/telegram-cli'
prod_daemon = File.dirname(__FILE__)+'/../tg/bin/telegram-cli'

daemon      = prod_daemon # dev_daemon #
contacts    = []

IO.popen("#{daemon} -W --json", "r+") {|f|
  phones.each do |phone|
    f.puts "add_contact \"#{phone[:phone]}\" \"_\" \"#{phone[:name]}\" "    
  end
  f.close_write
  f.each do |line|
    if line != nil
      if line.include? "{"
        contacts << line.split('"id":').last.split(',').first.strip
      end  
    end  
  end
}

IO.popen("#{daemon} -W --json", "r+") {|f|
  contacts.each do |contact|
    messages.each do |message|
      f.puts "msg user#" + contact +" "+ message 
    end  
  end
  f.close_write  
  #f.each do |line|
  #  puts line
  #end  
}  

puts "done"
