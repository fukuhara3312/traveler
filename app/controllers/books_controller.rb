def show
  @book = Book.find(params[:id])
  
  # 閲覧数を +1
  @book.increment!(:view_count)

  # Book に紐づく投稿を表示したい場合
  @posts = @book.posts.page(params[:page]).per(7).reverse_order
end
