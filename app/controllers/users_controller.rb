class UsersController < ApplicationController
  def index
    @users = User.page(params[:page]).per(5).reverse_order
  end
  
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.page(params[:page]).per(8).reverse_order
    @following_users = @user.following_user
    @follower_users = @user.follower_user

    @user = User.find_by(id: params[:id])
    # roomがcreateされた時に現在ログインしているユーザーと、
    # チャット相手になるユーザーの両方をEntriseテーブルから取得する。
    @current_entry = Entry.where(user_id: current_user.id)
    @another_entry = Entry.where(user_id: @user.id)
    unless @user.id == current_user.id
      @current_entry.each do |current|
        @another_entry.each do |another|
          if current.room_id == another.room_id
            @is_room = true
            @room_id = current.room_id
          end
        end
      end
      unless @is_room
        @room = Room.new
        @entry = Entry.new
      end
    end
    @posts = @user.posts.order(created_at: :desc).page(params[:page]).per(2)
    @like_posts = @user.favorites.order(created_at: :desc).page(params[:page]).per(2)
    @comment_posts = @user.comments.order(created_at: :desc).page(params[:page]).per(3)
  end

   def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    redirect_to user_path(@user.id)
  end

  def follows
    user = User.find(params[:id])
    @users = user.following_user.page(params[:page]).per(3).reverse_order
  end
  
  def followers
    user = User.find(params[:id])
    @users = user.follower_user.page(params[:page]).per(3).reverse_order
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :profile, :profile_image)
  end 

end
