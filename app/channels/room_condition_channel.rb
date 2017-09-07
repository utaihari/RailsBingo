class RoomConditionChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    logger.debug "room_condition_#{params[:room]}"
    stream_for "room_condition_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
