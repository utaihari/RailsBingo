# coding: utf-8

class CommunitiesController < ApplicationController
  def index
    @communities = Community.joins(:user).all
    @belong_communities = CommunityUserList.where(user_id: current_user.id)
  end

  def show
    @current_community = Community.find_by(params[:id])
    @members = CommunityUserList.joins(:user).where(community_id: params[:id])
  end

  def new
    @community = Community.new
  end

  def edit
  end

  def create
    @community = Community.new(name: params[:community][:name],user_id: current_user.id)
    if @community.save
      CommunityUserList.create(community_id: @community.id,user_id: current_user.id)
      # @userはuser_path(@user) に自動変換される
      redirect_to @community, notice: "作成しました"
    else
      # ValidationエラーなどでDBに保存できない場合 new.html.erb を再表示
      render 'new'
    end
  end

  def join
    if !CommunityUserList.exists?(community_id: params[:id], user_id: current_user)
      @community_user_list = CommunityUserList.create(community_id: params[:id], user_id: current_user.id)
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
    if CommunityUserList.exists?(community_id: params[:id], user_id: current_user.id)
      @community_user_list = CommunityUserList.find_by(community_id: params[:id], user_id: current_user.id)
      @community_user_list.destroy
    end
    redirect_to controller: 'communities', action: 'show', id: params[:id]
  end

  def update
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


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_community
    @community = Community.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def community_params
    params.require(:community).permit(:name, :user_id)
  end
end
