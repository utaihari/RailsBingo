# coding: utf-8
class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy, :add_number, :get_number]
  before_action :room_params, only: [:edit, :update, :destroy, :create]

  def index
  end

  def new
    @community = Community.find_by(params[:community_id])
    @room = @community.rooms.build
  end

  def create
    @community = Community.find_by(params[:community_id])

    if @community == nil
      redirect_to 'pages_index_path'
    end

    @room = @community.rooms.build(community_id: params[:community_id], name: params[:room][:name], canUseItem: params[:room][:canUseItem])

    if @room.save
      redirect_to controller: 'rooms', action: 'show', id: @room.id
    else
      redirect_to controller: 'communities', action: 'index', notice: "エラー"
    end
  end

  def show
    room_id = params[:id]
    @isRoomOrganizer =  isRoomOrganizer(room_id)
    @room = Room.find_by(room_id)

    if @community == nil || @room == nil
      redirect_to 'pages_index_path'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def join
    @community = Community.find_by(params[:community_id])
    @room = Room.find_by(params[:room_id])

    if @community == nil || @room == nil
      redirect_to 'pages_index_path'
    end

    if !RoomUserList.exists?(room_id: params[:room_id], user_id: current_user.id)
      @room_user_list = RoomUserList.new(room_id: params[:room_id], user_id: current_user.id)
      if @room_user_list.save
        redirect_to controller: 'bingo_cards', action: 'create', community_id: params[:community_id], room_id: params[:room_id]
      else
        redirect_to 'pages_index_path'
      end
    else
      redirect_to controller: 'bingo_cards', action: 'create', community_id: params[:community_id], room_id: params[:room_id]
    end
  end

  def add_number
    if @community == nil || @room == nil
      render :text => "不正なパラメータです"
    end
    if isRoomOrganizer(params[:room_id])
      RoomNumber.create(room_id: params[:room_id],number: params[:number])

      numbers = RoomNumber.where(room_id: params[:room_id]).select("number","rate")
      render :json => numbers
    else
      render :text => "ビンゴの主催者では有りません"
    end
  end

  def get_number
    if @community == nil || @room == nil
      render :text => "不正なパラメータです"
    end
    numbers = RoomNumber.where(room_id: params[:room_id]).select("number")
    render :json => numbers
  end
  private

  def set_room
    @room = Room.find(params[:id])
    @community = Community.find(params[:community_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def room_params
    params.require(:room).permit(:name, :canUseItem)
  end

  def isRoomOrganizer(room_id)
    return current_user.id == Room.joins(:community).find_by(room_id).community.user_id
  end
end
