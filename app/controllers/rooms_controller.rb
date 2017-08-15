# coding: utf-8
class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :room_params, only: [:update, :create]

  def index
  end

  def new
    @community = Community.find_by(id:params[:community_id])
    last_room = Room.order(updated_at: :desc).find_by(community_id: @community.id)
    if last_room == nil
      @room = @community.room.build
    else
      @room = Room.new(user_id:current_user.id, community_id: params[:community_id],\
      name: last_room.name, canUseItem: last_room.canUseItem, AllowGuest: last_room.AllowGuest,\
      AllowJoinDuringGame: last_room.AllowJoinDuringGame, detail: last_room.detail,\
      number_of_free: last_room.number_of_free.to_i, can_bring_item: last_room.can_bring_item,\
      profit: last_room.profit.to_i, bingo_score: last_room.bingo_score.to_f,\
      riichi_score: last_room.riichi_score.to_f, hole_score: last_room.hole_score.to_f,\
      invite_bonus: last_room.invite_bonus.to_i, show_hint: last_room.show_hint,\
      pass: last_room.pass, show_top_page: last_room.show_top_page)
    end
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
    date = params[:room][:date]
    if date == ""
      date = nil
    end
    @room = Room.new(user_id:current_user.id, community_id: params[:community_id], name: params[:room][:name], canUseItem: params[:room][:canUseItem], AllowGuest: params[:room][:AllowGuest],\
    AllowJoinDuringGame: params[:room][:AllowJoinDuringGame], detail: params[:room][:detail],\
    number_of_free: params[:room][:number_of_free].to_i, can_bring_item: params[:room][:can_bring_item], profit: params[:room][:profit].to_i,\
    bingo_score: params[:room][:bingo_score].to_f, riichi_score: params[:room][:riichi_score].to_f, hole_score: params[:room][:hole_score].to_f,\
    invite_bonus: params[:room][:invite_bonus].to_i, rates:number_rate.join(","), show_hint:params[:room][:show_hint],\
    pass: params[:room][:pass], show_top_page: params[:room][:show_top_page], date: date)

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

    @members = User.joins(:bingo_card).joins(:room_user_list).\
    where(:bingo_cards => {room_id: room_id}, :room_user_lists => {room_id: room_id}).\
    select("users.id AS id, users.name, bingo_cards.id AS card_id, bingo_cards.is_auto AS is_auto, users.last_sign_in_ip").order("bingo_cards.is_auto ASC, users.id ASC")
    @cards = BingoCard.where(room_id: @room.id).order("is_auto ASC, user_id ASC")

    @url = "http://www.bingo-live.tk"+pre_join_room_path(@community.id,@room.id)
    qrcode = RQRCode::QRCode.new(@url)
    @svg = qrcode.as_svg(offset: 0, color: '000',
      shape_rendering: 'crispEdges',
      module_size: 3)
    @items = Item.where("((item_type = ?) OR (item_type = ?) OR (item_type = ?)) AND (AllowUseDuringGame = 't')",0,2,4)
    @my_page_url = Settings.url[:url]
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
    session[:invite_by] = params[:invite_by]
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

  def join_auto
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
        settings = UserSetting.find_by(user_id: current_user.id)
        if settings == nil
          settings = UserSetting.create(user_id: current_user.id)
        end
        settings.is_auto = true
        settings.save!
        redirect_to controller: 'bingo_cards', action: 'create', community_id: params[:community_id], room_id: params[:room_id]
      else
        redirect_to controller: 'communities', action: 'index'
      end
    else
      settings = UserSetting.find_by(user_id: current_user.id)
      if settings == nil
        settings = UserSetting.create(user_id: current_user.id)
      end
      settings.is_auto = true
      settings.save!
      redirect_to controller: 'bingo_cards', action: 'create', community_id: params[:community_id], room_id: params[:room_id]
    end
  end



  def result
    @room = Room.joins(:community).joins(:user).find_by(id:params[:room_id])
    if !isRoomOrganizer(params[:room_id])
      render :text => "主催者ではありません"
    end
    @bingo_list = BingoUser.joins(:user).where(room_id: params[:room_id]).order("bingo_users.times ASC, bingo_users.seconds ASC").select("seconds","times","name","email","user_id","note")
    @room.isFinished = true
    @room.save
    @number_of_joined = RoomUserList.where(room_id: params[:room_id]).count
    if !@room.can_bring_item
      UserItemList.delete_all(room_id: @room.id, temp: true)
    end
    WebsocketRails["#{@room.id}"].trigger(:change_room_condition, 2)
  end

  def add_number
    @room = Room.joins(:community).joins(:user).find(params[:room_id])

    if params[:number] == nil
      render :json => "不正なパラメータです" and return
    end

    number = params[:number].to_i

    if @room == nil || number < 1 || 75 < number
      render :json => "不正なパラメータです" and return
    end

    if isRoomOrganizer(params[:room_id])
      RoomNumber.create(room_id: params[:room_id],number: params[:number])
      rates = @room.rates.split(",")
      @room.pre_rate = rates[number-1]
      rates[number-1] = 0
      @room.rates = rates.join(",")
      @room.times += 1
      @room.save
      room_notice = {}

      auto_cards = BingoCard.includes(:user).includes(:room).where(room_id: params[:room_id], is_auto: true)

      auto_cards.each do |card|
        card_numbers = card.numbers.split(",")
        card_checks = card.checks.split(",")
        card_numbers.each_with_index do |num, i|
          if num.to_i == number
            card_checks[i] = "t"
            card.holes += 1

            if !card.done_bingo
              riichi_lines = card.riichi_lines
              card.riichi_lines = calc_riichi_lines(card_checks)

              if riichi_lines != card.riichi_lines
                notice = "リーチ！(自動機能により登録されました)"
                user = User.find(card.user_id)
                RoomNotice.create!(room_id: params[:room_id], user_name: user.name, notice: notice, color: "magenta")
                room_notice << {user_name: user.name, notice: notice, color: "magenta"}
              end

              if check_bingo(card_checks)
                user = User.find(card.user_id)
                notice = "ビンゴ！(自動機能により登録されました)"
                RoomNotice.create!(room_id: params[:room_id], user_name: user.name, notice: notice, color: "red")
                room_notice << {user_name: user.name, notice: notice, color: "red"}
                # WebsocketRails["#{room.id}"].trigger(:add_notice, {user_name: current_user.name, notice: notice, color: "red"})
                card.bingo_lines += 1
                card.done_bingo = true
                BingoUser.create(room_id: params[:room_id], user_id: user.id, times: @room.times, seconds: 0, note:"自動ユーザー")
              end
            end
            card.checks = card_checks.join(",")

          end
        end
        card.save
      end
      WebsocketRails["#{@room.id}"].trigger(:websocket_add_number, params[:number])
      render :json => rates
    else
      render :json => "ビンゴの主催者では有りません"
    end
  end

  def get_notices
    length = params[:length].to_i
    notices_length = RoomNotice.where(room_id: params[:room_id]).order("created_at DESC").count

    notices_length -= length

    if notices_length > 0
      notices = RoomNotice.where(room_id: params[:room_id]).order("created_at DESC").limit(notices_length)
    end

    render :json => notices.to_json

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

  def game_main
    @community = Community.find(params[:community_id])
    @room = Room.joins(:community).joins(:user).find(params[:room_id])
    if @room == nil
      render :json => "不正なパラメータです" and return
    end
    @room.isPlaying = true
    @room.save

    RoomNumber.create(room_id: params[:room_id], number: -1)
    auto_cards = BingoCard.where(room_id: params[:room_id], is_auto: true)
    auto_cards.each do |card|
      card_numbers = card.numbers.split(",")
      card_checks = card.checks.split(",")
      card_numbers.each_with_index do |num, i|
        if num.to_i == -1
          card_checks[i] = "t"
          card.checks = card_checks.join(",")
          card.holes += 1
        end
      end
      card.save
    end
    WebsocketRails["#{@room.id}"].trigger(:change_room_condition, 1)
  end

  def member_list
    @room = Room.joins(:community).joins(:user).find(params[:room_id])
    @members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: params[:room_id]}, :room_user_lists => {room_id: params[:room_id]}).select("users.id AS id, users.name, bingo_cards.id AS card_id, bingo_cards.is_auto AS is_auto, users.last_sign_in_ip").order("bingo_cards.is_auto ASC, users.id ASC")
    @cards = BingoCard.where(room_id:@room.id).order("is_auto ASC, user_id ASC")
    @room_mastar = isRoomOrganizer(params[:room_id])
  end

  def use_item_tool
    @members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: params[:room_id]}, :room_user_lists => {room_id: params[:room_id]}).select("users.id AS id, users.name, bingo_cards.id AS card_id").order("bingo_cards.is_auto ASC, users.id ASC")
    @items = Item.where("((item_type = ?) OR (item_type = ?) OR (item_type = ?)) AND (AllowUseDuringGame = 't')",0,2,4)
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

  def get_user_notices
    if params[:room_id] == nil
      render :json => "不正なパラメータです" and return
    end
    notice_records = UserNotice.where(user_id: current_user.id, room_id: params[:room_id])
    notices = []
    notice_records.each do |n|
      notices.push(n.notice)
    end
    if notices.length != 0
      notice_records.delete_all
    end
    render :json => notices.to_json
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
    users = BingoUser.joins(:user).where(room_id: params[:room_id]).order("bingo_users.times ASC, bingo_users.seconds ASC").select("Users.name","times","seconds","note")
    render :json => users and return
  end

  def joined_users
    @members = User.joins(:room_user_list).where(:room_user_lists => {room_id: params[:room_id]})
    render :json => @members and return
  end

  #TOOLS
  def tool_number_generator
    @room = Room.find(params[:room_id])
    render "_number-generator", :locals => { room: @room, isWindow: true },:layout => false and return
  end
  def tool_qr_code
    @room = Room.find(params[:room_id])
    @community = Community.find(params[:community_id])
    @url = "http://www.bingo-live.tk"+pre_join_room_path(@community.id,@room.id)
    qrcode = RQRCode::QRCode.new(@url)
    @svg = qrcode.as_svg(offset: 0, color: '000',
      shape_rendering: 'crispEdges',
      module_size: 3)
    render :partial => "qr-code", :locals => { room:@room, svg: @svg, url: @url, isWindow: true }, :layout => false and return
  end
  def tool_bingo_users
    @room = Room.find(params[:room_id])
    render :partial => "bingo-users", :locals => {isWindow: true}, :layout => false and return
  end
  def tool_notices
    render :partial => "notices", :locals => {room_id: params[:room_id], isWindow: true}, :layout => false and return
  end
  def tool_members
    @room = Room.find(params[:room_id])
    @members = User.joins(:bingo_card).joins(:room_user_list).where(:bingo_cards => {room_id: params[:room_id]}, :room_user_lists => {room_id: params[:room_id]}).select("users.id AS id, users.name, bingo_cards.id AS card_id, bingo_cards.is_auto AS is_auto, users.last_sign_in_ip")
    @cards = BingoCard.where(room_id:@room.id).order("user_id ASC")
    @room_master = isRoomOrganizer(params[:room_id])
    logger.debug("room_id: "+@room.id.to_s)
    render :partial => "members", :locals => {members: @members, room_id: @room.id, cards: @cards, isWindow: true, room_master: @room_master}, :layout => false and return
  end

  private

  def check_bingo(checks)
    # Alignment bingocard sequence
    # 0  1  2  3  4
    # 5  6  7  8  9
    # 10 11 12 13 14
    # 15 16 17 18 19
    # 20 21 22 23 24

    #check horizontal line
    for i in 0..4
      if checks[i*5+0] == "t" && checks[i*5+1] == "t" && checks[i*5+2] == "t" && checks[i*5+3] == "t" && checks[i*5+4] == "t"
        return true
      end
    end
    #check vertical line
    for i in 0..4
      if checks[i+0] == "t" && checks[i+5] == "t" && checks[i+10] == "t" && checks[i+15] == "t" && checks[i+20] == "t"
        return true
      end
    end
    #check diagonal line
    if checks[0] == "t" && checks[6] == "t" && checks[12] == "t" && checks[18] == "t" && checks[24] == "t"
      return true
    end
    if checks[4] == "t" && checks[8] == "t" && checks[12] == "t" && checks[16] == "t" && checks[20] == "t"
      return true
    end
    return false
  end

  def calc_riichi_lines(checks)
    holes = []
    number_of_one_left_line = 0
    for check in checks
      if check == "t"
        holes.push(1)
      else
        holes.push(0)
      end
    end
    for i in 0..4
      if (holes[i*5+0]+holes[i*5+1]+holes[i*5+2]+holes[i*5+3]+holes[i*5+4]) == 4
        number_of_one_left_line += 1
      end
    end
    for i in 0..4
      if (holes[i+0]+holes[i+5]+holes[i+10]+holes[i+15]+holes[i+20]) == 4
        number_of_one_left_line += 1
      end
    end
    if (holes[0]+holes[6]+holes[12]+holes[18]+holes[24]) == 4
      number_of_one_left_line += 1
    end
    if (holes[4]+holes[8]+holes[12]+holes[16]+holes[20]) == 4
      number_of_one_left_line += 1
    end
    return number_of_one_left_line
  end


  def set_room
    @room = Room.find(params[:id])
    @community = Community.find(params[:community_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def room_params
    params.require(:room).permit(:name, :canUseItem, :AllowGuest, :AllowJoinDuringGame,\
    :detail, :profit, :bingo_score, :riichi_score, :hole_score, :number_of_free, :can_bring_item,\
    :invite_bonus, :show_hint, :pass, :show_top_page, :date)
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
