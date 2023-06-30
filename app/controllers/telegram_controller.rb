class TelegramController < Telegram::Bot::UpdatesController
  def start!(*)
    puts 'hellow'

    respond_with :message, text: 'hello!'
  end
end
