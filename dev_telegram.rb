# encoding: utf-8
lib = File.join(File.dirname(__FILE__), 'lib')
$:.unshift lib unless $:.include?(lib)

require 'eventmachine'
require 'telegram'
require 'json'

EM.run do
  telegram = Telegram::Client.new do |cfg|
    cfg.daemon = '../../../../tests/tg/bin/telegram-cli'
    cfg.key    = 'tg-server.pub'
  end
 
  telegram.connect do
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
    telegram.chats.each do |chat|
      puts chat
    end
    
    exit
    #telegram.on[Telegram::EventType::RECEIVE_MESSAGE] = Proc.new { |ev|
      
    #}
  end
end
