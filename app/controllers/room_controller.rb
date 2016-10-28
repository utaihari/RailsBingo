class RoomController < ApplicationController

	def index
	end

	def new
		@community_id = params[:id]
	end

	def create

	end

	def show
	end

	def edit
	end

	def update
	end
	
	def destroy
	end

	def add_number

		RoomNumber.create(room_id: params[:room_id],number: params[:number])
	end

	private

	# Never trust parameters from the scary internet, only allow the white list through.
	def room_params
		params.require(:room).permit(:room_id, :number)
	end
end
