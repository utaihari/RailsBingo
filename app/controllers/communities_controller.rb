# coding: utf-8

class CommunitiesController < ApplicationController
  before_action :set_community, only: [:show, :edit, :update, :destroy, :join]
  before_action :community_params, only: [:create, :update]

  def index
    @communities = Community.joins(:user).all.includes(:user)
    @belong_communities = CommunityUserList.where(user_id: current_user.id)
  end

  def show
    @members = CommunityUserList.joins(:user).where(community_id: params[:id]).includes(:user)
    @isOrganizer = isCommunityOrganizer(params[:id])
    @isMember = CommunityUserList.exists?(community_id:params[:id], user_id: current_user)
    @opened_rooms = Room.where(community_id:params[:id], isFinished: false)
    @closed_rooms = Room.where(community_id:params[:id], isFinished: true)
    @organizer = User.find_by(id:@community.user_id)
    @isCreator = Community.exists?(id: params[:id], user_id: current_user.id)
  end

  def new
    @community = Community.new
  end

  def edit
  end

  def member_list
    @community = Community.find(params[:id])
    organizers = CommunityAdministrator.where(community_id: params[:id])
    @organizers = []
    organizers.each do |o|
      @organizers.push(o.user_id)
    end
    @members = CommunityUserList.joins(:user).where(community_id: params[:id]).select("users.name, users.id")
  end

  def create
    @community = Community.new(user_id: current_user.id, name: params[:community][:name], detail: params[:community][:detail])
    if @community.save!
      CommunityUserList.create(community_id: @community.id,user_id: current_user.id)
      CommunityAdministrator.create(community_id: @community.id,user_id: current_user.id)
      # @userはuser_path(@user) に自動変換される
      redirect_to action: "show", id: @community.id, notice:"作成しました" and return
    else
      # ValidationエラーなどでDBに保存できない場合 new.html.erb を再表示
      render 'new'
    end
  end

  def join
    if @community == nil
      redirect_to pages_index_path and return
    end
    if !CommunityUserList.exists?(community_id: params[:id], user_id: current_user.id)
      @community_user_list = CommunityUserList.new(community_id: params[:id], user_id: current_user.id)
      if @community_user_list.save
        redirect_to controller: 'communities', action: 'show', id: params[:id]
      else
        redirect_to controller: 'communities', action: 'show', id: params[:id]
      end
    else
      redirect_to controller: 'communities', action: 'show', id: params[:id]
    end
  end

  def leave
    if @community == nil
      redirect_to 'pages_index_path'
    end
    if CommunityUserList.exists?(community_id: params[:id], user_id: current_user.id)
      @community_user_list = CommunityUserList.find_by(community_id: params[:id], user_id: current_user.id)
      @community_user_list.destroy
    end
    redirect_to controller: 'communities', action: 'show', id: params[:id]
  end

  def update
    @community.update(community_params)
    redirect_to controller: 'communities', action: 'show', id: params[:id]
  end

  def destroy
    @community = Community.find(params[:id])
    @community.destroy
    respond_to do |format|
      format.html { redirect_to communities_url, notice: '削除しました' }
      format.json { head :no_content }
    end
  end

  def show_own_communities
    @communities = Community.where(user_id: current_user.id)
  end

  def toggle_administrator
    community_id = params[:community_id]
    user_id = params[:user_id]

    if !Community.exists?(id: community_id, user_id: current_user.id)
      render :json => "error".to_json
    end

    if CommunityAdministrator.exists?(community_id: community_id, user_id: user_id)
      CommunityAdministrator.find_by(community_id: community_id, user_id: user_id).destroy
      render :json => false.to_json
    else
      CommunityAdministrator.create(community_id: community_id, user_id: user_id)
      render :json => true.to_json
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_community
    @community = Community.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def community_params
    params.require(:community).permit(:name, :detail)
  end

  def isCommunityOrganizer(community_id)
    return CommunityAdministrator.exists?(community_id: community_id,user_id: current_user.id)
  end
end
