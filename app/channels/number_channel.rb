class NumberChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    logger.debug "subscribed number_#{params[:room]}"
    stream_for "number_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
