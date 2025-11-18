class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @room = Room.find(params[:room_id])

    return redirect_back(fallback_location: root_path) unless
      @room.entries.exists?(user_id: current_user.id)

    @message = @room.messages.new(message_params)
    @message.user_id = current_user.id

    if @message.save
      redirect_to room_path(@room)
    else
      @messages = @room.messages.order(created_at: :asc)
      render "rooms/show"
    end
  end

  private

  def message_params
    params.require(:message).permit(:message)
  end
end