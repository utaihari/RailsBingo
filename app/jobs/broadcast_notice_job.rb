class BroadcastNoticeJob < ApplicationJob
  queue_as :default

  def perform(message)
    NoticeChannel.broadcast_to("notice_#{message.room_id}", notice: message)
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: messages/message, locals: { message: message })
  end
end