class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]

  def index
    @posts = collection_scope.includes(:author).order(created_at: :desc)
    @posts = @posts.page(params[:page]).per(15)
  end

  def destroy
    @post = Post.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to @post.graetzl, notice: 'Beitrag gelöscht' }
      format.js
    end
  end

  private

  def collection_scope
    if params[:graetzl_id]
      graetzl = Graetzl.find(params[:graetzl_id])
      Post.where("(id IN (:posts)) OR (id IN (:admin_posts))",
        posts: graetzl.posts.where(type: 'UserPost').ids,
        admin_posts: graetzl.admin_posts.ids
      )
    else
      Post.all
    end
  end
end
