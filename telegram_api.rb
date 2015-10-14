# encoding: utf-8
# +0018188050365

lib = File.join(File.dirname(__FILE__), 'lib')
$:.unshift lib unless $:.include?(lib)

require 'google/api_client'
require 'google_drive'
require 'eventmachine'
require 'telegram'
require 'json'
require 'typhoeus'

CLIENT_ID          = "833494348776-pme294i5e5bui19d9e3nj3g9mhov6lgj.apps.googleusercontent.com"
CLIENT_SECRET      = "k0CwXlTPOcF18OvUI1FiRNhG"
REFRESH_TOKEN      = "1/LdkEyZQ5oP9NUQlEU6lgMiFEoGGv9dxCYZGGGfAhvvA"

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

dev_daemon  = File.dirname(__FILE__)+'/../../../../tests/tg/bin/telegram-cli'
prod_daemon = File.dirname(__FILE__)+'/../tg/bin/telegram-cli'

#drive_session   = GoogleDrive.login_with_oauth(refresh_token)
#worksheet       = drive_session.file_by_title(SHEET_NAME).worksheets.last

default_message = worksheet[2, 4]

# rm -rf .telegram-cli/
# run telegram-cli
# add new phone number

EM.run do
  telegram = Telegram::Client.new do |cfg|
    cfg.daemon = prod_daemon
  end

  telegram.connect do
=begin     
    (2..worksheet.num_rows).each do |row|
      telegram.add_contact("+"+worksheet[row, 1].strip, "_", worksheet[row, 3].strip) do |success, data| 
        puts success
        puts data     
        message = worksheet[row, 4].strip == "" ? default_message : worksheet[row, 4].strip
        telegram.msg(data[0]['type']+"#"+data[0]['id'].to_s, message) do |success, dat|
          puts dat
        end
      end
    end
=end    
    #telegram.msg("m_de(124284736)", "Hi Yahya")
    #telegram.update_contacts!
    #telegram.add_contact("+212690586989", "sara", "yahya") do |success, data|      
    #  telegram.msg(data[0]['type']+"#"+data[0]['id'].to_s, "Hi Sara") do |success, dat|
    #    puts dat
    #  end
    #end  
  
    #puts telegram.methods
    #puts telegram.profile

    #c = Telegram::TelegramContact.pick_or_new(telegram, {'print_name' => 'rahmani', 'phone' => '+21290586989', 'username' => 'yahya'} )
    #puts c

    telegram.contacts.each do |contact|
      puts contact
    end
#    telegram.chats.each do |chat|
#      puts chat
#    end
#    exit 0    
  end
end
