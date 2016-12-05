# coding: utf-8
class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :room_params, only: [:update, :create]

  def index
  end

  def new
    @community = Community.find_by(id:params[:community_id])
    @room = @community.room.build
  end
  def direct_new
    @community = Community.find(0)
    @communities = Community.joins(:community_administrator).where('community_administrators.user_id = ?', current_user.id)
    @room = @community.room.build

    if @communities.length == 1
      redirect_to controller: 'rooms', action: 'new', community_id: @communities[0].id
    end
  end
  def create
    @community = Community.find_by(id:params[:community_id])

    if @community == nil
      redirect_to 'pages_index_path'
    end

    number_rate = Array.new(75,10)
    @room = @community.room.build(user_id:current_user.id, community_id: params[:community_id], name: params[:room][:name], canUseItem: params[:room][:canUseItem], AllowGuest: params[:room][:AllowGuest], AllowJoinDuringGame: params[:room][:AllowJoinDuringGame], detail: params[:room][:detail], number_of_free: params[:room][:number_of_free].to_i, can_bring_item: params[:room][:can_bring_item], profit: params[:room][:profit].to_i, bingo_score: params[:room][:bingo_score].to_f, riichi_score: params[:room][:riichi_score].to_f, hole_score: params[:room][:hole_score].to_f, rates:number_rate.join(","))

    if @room.save
      redirect_to controller: 'rooms', action: 'show', id: @room.id
    else
      redirect_to controller: 'communities', action: 'index', notice: "エラー"
    end
  end

  def direct_create
    params.require(:community).permit(:id)
    redirect_to controller: 'rooms', action: 'new', community_id: params[:community][:id]
  end

  def show
    room_id = params[:id]
    @isRoomOrganizer =  isRoomOrganizer(room_id)
    @isRoomMember = isRoomMember(room_id, current_user.id)
    if @isRoomMember
      @card = BingoCard.find_by(user_id:current_user.id, room_id:room_id)
    end
    @room = Room.find(room_id)

    if @community == nil || @room == nil
      redirect_to 'pages_index_path'
    end
    @members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: room_id}, :room_user_lists => {room_id: room_id}).select("users.id AS id, users.name, bingo_cards.id AS card_id")

    @url = "http://"+request.domain+pre_join_room_path(@community.id,@room.id)
    qrcode = RQRCode::QRCode.new(@url)
    @svg = qrcode.as_svg(offset: 0, color: '000',
      shape_rendering: 'crispEdges',
      module_size: 3)
  end

  def edit
  end

  def update
    @room.update(room_params)
    redirect_to controller: 'rooms', action: 'show', community_id: params[:community_id], id: params[:id]
  end

  def destroy
    @community = Community.find(params[:community_id])
    @room = Room.find(params[:id])
    @room.destroy
    respond_to do |format|
      format.html { redirect_to community_path(params[:community_id]), notice: '削除しました' }
      format.json { head :no_content }
    end
  end

  def pre_join
    @community = Community.find_by(id:params[:community_id])
    @room = Room.find_by(id:params[:room_id])
    @user_signed_in = user_signed_in?
    if @community == nil || @room == nil
      redirect_to controller: 'communities', action: 'index'
    end
  end

  def join
    if !user_signed_in?
      render 'pre_join'
    end
    @community = Community.find_by(id:params[:community_id])
    @room = Room.find_by(id:params[:room_id])

    if @community == nil || @room == nil
      redirect_to controller: 'communities', action: 'index'
    end
    if !@room.AllowJoinDuringGame && @room.isPlaying
      render :text => "error"
    end
    if !isCommunityMember(@community.id)
      CommunityUserList.create(community_id: @community.id, user_id: current_user.id)
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

  def result
    @room = Room.joins(:community).joins(:user).find_by(id:params[:room_id])
    if !isRoomOrganizer(params[:room_id])
      render :text => "主催者ではありません"
    end
    @bingo_list = BingoUser.joins(:user).where(room_id: params[:room_id]).order("bingo_users.times ASC, bingo_users.seconds ASC").select("seconds","times","name","email")
    @room.isFinished = true
    @room.save
    if !@room.can_bring_item
      UserItemList.destroy_all(room_id: @room.id, temp: true)
    end
  end

  def add_number
    @room = Room.joins(:community).joins(:user).find(params[:room_id])

    if params[:number] == nil
      render :json => "不正なパラメータです" and return
    end

    number = Integer(params[:number])

    if @room == nil || number < 1 || 75 < number
      render :json => "不正なパラメータです" and return
    end

    if isRoomOrganizer(params[:room_id])
      RoomNumber.create(room_id: params[:room_id],number: params[:number])
      rates = @room.rates.split(",")
      rates[number-1] = 0
      @room.rates = rates.join(",")
      @room.save
      render :json => rates
    else
      render :json => "ビンゴの主催者では有りません"
    end
  end

  def get_number
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
      render :json => "不正なパラメータです" and return
    end
    numbers = @room.rates.split(",")
    return_nums = []
    numbers.each { |num|
      return_nums << num.to_f
    }
    render :json => return_nums
  end

  def check_condition
    @room = Room.find_by(id: params[:room_id])
    if @room == nil
      render :json => "不正なパラメータです" and return
    end

    if @room.isFinished
      render :json => 2 and return
    end

    if @room.isPlaying
      render :json => 1 and return
    else
      render :json => 0 and return
    end
    return
  end

  def start_game
    @room = Room.joins(:community).joins(:user).find_by(id: params[:room_id])
    if @room == nil
      render :json => "不正なパラメータです" and return
    end
    @room.isPlaying = true
    @room.save

    RoomNumber.create(room_id: @room.id, number: -1)
  end

  def check_rank
    if params[:room_id] == nil
      render :json => "不正なパラメータです" and return
    end
    bingo_users = BingoUser.where(room_id: params[:room_id]).order("bingo_users.times ASC, bingo_users.seconds ASC")
    ranking = 0
    bingo_users.each_with_index do |user, i|
      if user.user_id == current_user.id
        ranking = i+1
      end
    end
    render :json => ranking
    return
  end

  def view_mail_address
    if !isRoomOrganizer(params[:room_id]) || !isRoomMember(params[:room_id],params[:user_id])
      render :json => "不正なパラメータです" and return
    end
    user = User.find_by(params[:user_id])
    if user == nil
      render :json => "不正なパラメータです" and return
    end
    render :json => user.email
  end

  def check_bingo_users
    if !isRoomOrganizer(params[:room_id])
      render :json => "不正なパラメータです" and return
    end
    users = BingoUser.joins(:user).where(room_id: params[:room_id]).order("bingo_users.times ASC, bingo_users.seconds ASC").select("Users.name","times","seconds")
    render :json => users and return
  end

  def joined_users
    @members = User.joins(:room_user_list).where(:room_user_lists => {room_id: params[:room_id]})
    render :json => @members and return
  end

  #TOOLS
  def tool_number_generator
    @room = Room.find(params[:room_id])
    render "_number-generator", :locals => { room: @room },:layout => false and return
  end
  def tool_qr_code
    @room = Room.find(params[:room_id])
    @community = Community.find(params[:community_id])
    @url = "http://"+request.domain+pre_join_room_path(@community.id,@room.id)
    qrcode = RQRCode::QRCode.new(@url)
    @svg = qrcode.as_svg(offset: 0, color: '000',
      shape_rendering: 'crispEdges',
      module_size: 3)
    render :partial => "qr-code", :locals => { room:@room, svg: @svg, url: @url }, :layout => false and return
  end
  def tool_bingo_users
    @room = Room.find(params[:room_id])
    render :partial => "bingo-users", :layout => false and return
  end
  def tool_members
    @room = Room.find(params[:room_id])
    @members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: params[:room_id]}, :room_user_lists => {room_id: params[:room_id]}).select("users.id AS id, users.name, bingo_cards.id AS card_id")
    render :partial => "members", :locals => {members: @members, room_id: @room.id }, :layout => false and return
  end

  private

  def set_room
    @room = Room.find(params[:id])
    @community = Community.find(params[:community_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def room_params
    params.require(:room).permit(:name, :canUseItem, :AllowGuest, :AllowJoinDuringGame, :detail, :profit, :bingo_score, :riichi_score, :hole_score, :number_of_free, :can_bring_item)
  end

  def isRoomOrganizer(room_id)
    return current_user.id == Room.find_by(id:room_id).user_id
  end
  def isCommunityMember(community_id)
    return CommunityUserList.exists?(community_id:community_id, user_id: current_user.id)
  end
  def isRoomMember(room_id)
    return RoomUserList.exists?(room_id: room_id, user_id: current_user.id)
  end
  def isRoomMember(room_id,user_id)
    return RoomUserList.exists?(room_id: room_id, user_id: user_id)
  end
end
