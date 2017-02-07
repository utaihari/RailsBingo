class ChangeLogsController < ApplicationController
  before_action :set_change_log, only: [:show, :edit, :update, :destroy]

  # GET /change_logs
  # GET /change_logs.json
  def index
    @change_logs = ChangeLog.where(log_type:0).order("created_at DESC")
    @to_be_released = ChangeLog.where(log_type:1).order("created_at DESC")
    @to_be_resolved = ChangeLog.where(log_type:2).order("created_at DESC")
    @is_admin = AdminUser.exists?(user_id: current_user.id)
  end

  # GET /change_logs/1
  # GET /change_logs/1.json
  def show
  end

  # GET /change_logs/new
  def new
    @change_log = ChangeLog.new
  end

  # GET /change_logs/1/edit
  def edit
  end

  # POST /change_logs
  # POST /change_logs.json
  def create
    @change_log = ChangeLog.new(change_log_params)

    respond_to do |format|
      if @change_log.save
        format.html { redirect_to @change_log, notice: 'Change log was successfully created.' }
        format.json { render :show, status: :created, location: @change_log }
      else
        format.html { render :new }
        format.json { render json: @change_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /change_logs/1
  # PATCH/PUT /change_logs/1.json
  def update
    respond_to do |format|
      if @change_log.update(change_log_params)
        format.html { redirect_to @change_log, notice: 'Change log was successfully updated.' }
        format.json { render :show, status: :ok, location: @change_log }
      else
        format.html { render :edit }
        format.json { render json: @change_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /change_logs/1
  # DELETE /change_logs/1.json
  def destroy
    @change_log.destroy
    respond_to do |format|
      format.html { redirect_to change_logs_url, notice: 'Change log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_change_log
      @change_log = ChangeLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def change_log_params
      params.require(:change_log).permit(:body, :log_type, :title, :change_date)
    end
end
