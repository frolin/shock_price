class TelegramController < Telegram::Bot::UpdatesController
  def start!(*)
    if user.present?
      respond_with :message, text: "found: #{user.username}"
    else
      user = User.create!(chat_id: from['id'],
                   username: from['username'],
                   first_name: from['first_name'])

      respond_with :message, text: "hello! #{user.username}"
    end
  end

  private

  def user
    @user ||= User.find_by(chat_id: from['id'])
  end

end
