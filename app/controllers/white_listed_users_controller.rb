class WhiteListedUsersController < ApplicationController

  before_action :set_white_listed_user, only: [:show, :edit, :update, :destroy]

  def index
    @w_users = WhiteListedUser.all
    @new_w_user = WhiteListedUser.new
  end

  def show
  end

  def new
    @w_user = WhiteListedUser.new
  end

  def edit
  end

  def create
    @w_user = WhiteListedUser.new(white_listed_user_params)

    respond_to do |format|
      if @w_user.save
        format.html { redirect_to white_listed_users_path, notice: 'White Listed User was successfully created.' }
        format.json { render :show, status: :created, location: @w_user }
      else
        format.html { redirect_to white_listed_users_path, flash: {error: "White listed user not found."} }
        format.json { render json: @w_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    #respond_to do |format|
      #if @case.update(case_params)
        #format.html { redirect_to @case, notice: 'Case was successfully updated.' }
        #format.json { render :show, status: :ok, location: @case }
      #else
        #format.html { render :edit }
        #format.json { render json: @case.errors, status: :unprocessable_entity }
      #end
    #end
  end

  def destroy
    @w_user.destroy
    respond_to do |format|
      format.html { redirect_to white_listed_users_path, notice: 'w user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_white_listed_user
      @w_user = WhiteListedUser.find(params[:id])
    end

    def white_listed_user_params
      params.require(:white_listed_user).permit(:email, :name )
    end
end
