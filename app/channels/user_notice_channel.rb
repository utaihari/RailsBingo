class UserNoticeChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    logger.debug "subscribed user_notice_#{params[:user_id]}"
    stream_for "user_notice_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
