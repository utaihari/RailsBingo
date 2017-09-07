class NoticeChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    logger.debug "subscribed notice_#{params[:room]}"
    stream_for "notice_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
