class RoomsController < ApplicationController
  before_action :authenticate_user!

  # -----------------------------
  # ルーム一覧（相手の一覧）
  # -----------------------------
  def index
    # 自分が参加しているroom_id一覧
    my_room_ids = current_user.entries.pluck(:room_id)

    # 相手のentry（＝自分以外のユーザーが入っているroom）
    @another_entries = Entry
                         .where(room_id: my_room_ids)
                         .where.not(user_id: current_user.id)
                         .preload(room: :messages)
                         .preload(user: { icon_attachment: :blob })
  end

  # -----------------------------
  # ルーム作成（初回DM開始）
  # -----------------------------
  def create
    @room = Room.create

    # 自分
    @room.entries.create(user_id: current_user.id)

    # 相手
    another_user_id = params.dig(:entry, :user_id)
    @room.entries.create(user_id: another_user_id)

    redirect_to room_path(@room)
  end

  # -----------------------------
  # ルーム表示（メッセージ一覧）
  # -----------------------------
  def show
    @room = Room.find(params[:id])

    # 自分がこのroomに参加しているか確認
    unless @room.entries.exists?(user_id: current_user.id)
      return redirect_back(fallback_location: root_path)
    end

    @entries = @room.entries.includes(:user)

    # 相手ユーザー
    @another_user = @entries.where.not(user_id: current_user.id).first&.user

    # メッセージ一覧
    @messages = @room.messages.order(created_at: :asc)

    # 新規メッセージフォーム用
    @message = Message.new
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end
end