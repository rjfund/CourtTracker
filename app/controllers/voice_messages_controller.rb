class VoiceMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  before_action :set_voice_message, only: [:show, :edit, :update, :destroy]

  # GET /voice_messages
  # GET /voice_messages.json
  def index
    @voice_messages = VoiceMessage.all
  end

  # GET /voice_messages/1
  # GET /voice_messages/1.json
  def show
  end

  # GET /voice_messages/new
  def new
    @voice_message = VoiceMessage.new
  end

  # GET /voice_messages/1/edit
  def edit
  end

  # POST /voice_messages
  # POST /voice_messages.json
  def create

    @voice_message = VoiceMessage.new

    @voice_message.user = User.first
    @voice_message.is_new = true

    @voice_message.url = params['RecordingUrl']

    respond_to do |format|
      if @voice_message.save
        format.html { redirect_to @voice_message, notice: 'Voice message was successfully created.' }
        format.json { render :show, status: :created, location: @voice_message }
      else
        format.html { render :new }
        format.json { render json: @voice_message.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /voice_messages/1
  # PATCH/PUT /voice_messages/1.json
  def update
    @voice_message.is_new = !@voice_message.is_new
    @voice_message.save
    respond_to do |format|
      format.html { redirect_to voice_messages_url, notice: 'Marked Done' }
      format.json { head :no_content }
    end
  end

  # DELETE /voice_messages/1
  # DELETE /voice_messages/1.json
  def destroy
    @voice_message.destroy
    respond_to do |format|
      format.html { redirect_to voice_messages_url, notice: 'Voice message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voice_message
      @voice_message = VoiceMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voice_message_params
      params.require(:voice_message).permit(:url, :user_id, :is_new)
    end
end
