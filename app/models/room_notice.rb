class RoomNotice < ApplicationRecord
  	after_create_commit { BroadcastNoticeJob.perform_later self }
	belongs_to :room
end
