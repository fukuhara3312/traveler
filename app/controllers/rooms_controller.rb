class RoomsController < ApplicationController
  before_action :authenticate_user!

  def create
    @room = Room.create
    @current_entry = @room.entries.create(user_id: current_user.id)
    another_user_id = params.dig(:entry, :user_id)
    if another_user_id
        @another_entry = @room.entries.create(user_id: another_user_id)
    end
    redirect_to room_path(@room)
  end

  def index
    my_room_id = current_user.entries.pluck(:room_id)
    @another_entries = Entry
                       .where(room_id: my_room_id)
                       .where.not(user_id: current_user.id)
                       .preload(room: :messages).preload(user: { icon_attachment: :blob })
  end

  def show
    @room = Room.find(params[:id])
    if @room.entries.where(user_id: current_user.id).present?
      @messages = @room.messages.all
      @message = Message.new
      @entries = @room.entries
      # 相手ユーザーの Entry を取得
      @another_entry = @entries.where.not(user_id: current_user.id).first
      @another_entry ||= OpenStruct.new(user: OpenStruct.new(name: "UserName"))
    else
      redirect_back(fallback_location: root_path)
    end
  end
end