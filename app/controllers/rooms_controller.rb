# coding: utf-8
class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :room_params, only: [:edit, :update, :create]

  def index
  end

  def new
    @community = Community.find_by(id:params[:community_id])
    @room = @community.rooms.build
  end

  def create
    @community = Community.find_by(id:params[:community_id])

    if @community == nil
      redirect_to 'pages_index_path'
    end

    number_rate = Array.new(75,10)
    @room = @community.rooms.build(community_id: params[:community_id], name: params[:room][:name], canUseItem: params[:room][:canUseItem], rates:number_rate.join(","))

    if @room.save
      RoomNumber.create(room_id:params[:room_id],number:-1)
      redirect_to controller: 'rooms', action: 'show', id: @room.id
    else
      redirect_to controller: 'communities', action: 'index', notice: "エラー"
    end
  end

  def show
    room_id = params[:id]
    @isRoomOrganizer =  isRoomOrganizer(room_id)
    @room = Room.find(room_id)

    if @community == nil || @room == nil
      redirect_to 'pages_index_path'
    end
    @members = User.joins(:room_user_list).where(:room_user_lists => {room_id: room_id})
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def join
    @community = Community.find_by(id:params[:community_id])
    @room = Room.find_by(id:params[:room_id])

    if @community == nil || @room == nil
      redirect_to controller: 'communities', action: 'index'
    end

    if !isCommunityMember(community.id)
      render :text => "このコミュニティのメンバーではありません"
    end


    if !RoomUserList.exists?(room_id: params[:room_id], user_id: current_user.id)
      @room_user_list = RoomUserList.new(room_id: params[:room_id], user_id: current_user.id)
      if @room_user_list.save
        redirect_to controller: 'bingo_cards', action: 'create', community_id: params[:community_id], room_id: params[:room_id]
      else
        redirect_to controller: 'communities', action: 'index'
      end
    else
      redirect_to controller: 'bingo_cards', action: 'create', community_id: params[:community_id], room_id: params[:room_id]
    end
  end

  def add_number
    @room = Room.find(params[:room_id])
    @community = Community.find(params[:community_id])

    if params[:number] == nil
      render :text => "不正なパラメータです" and return
    end

    number = Integer(params[:number])

    if @community == nil || @room == nil || number < 1 || 75 < number
      render :text => "不正なパラメータです" and return
    end

    if isRoomOrganizer(params[:room_id])
      RoomNumber.create(room_id: params[:room_id],number: params[:number])
      rates = @room.rates.split(",")
      rates[number-1] = 0
      @room.rates = rates.join(",")
      @room.save
      render :json => rates
    else
      render :text => "ビンゴの主催者では有りません"
    end
  end

  def get_number
    @room = Room.find(params[:room_id])
    if @room == nil
      render :text => "不正なパラメータです" and return
    end
    numbers = RoomNumber.where(room_id: params[:room_id]).select("number")
    return_nums = []
    numbers.each { |num|
      return_nums << num.number
    }
    render :json => return_nums
  end

  def get_number_rate
    @room = Room.find_by(id: params[:room_id])
    if @room == nil || !isRoomOrganizer(params[:room_id])
      render :text => "不正なパラメータです" and return
    end
    numbers = @room.rates.split(",")
    return_nums = []
    numbers.each { |num|
      return_nums << Integer(num)
    }
    render :json => return_nums
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
    return current_user.id == Room.joins(:community).find_by(id: room_id).community.user_id
  end
  def isCommunityMember(community_id)
    return CommunityUserList.exists?(community_id:community_id, user_id: current_user.id)
  end
end
