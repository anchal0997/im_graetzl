require 'rails_helper'

RSpec.describe CommentsController, type: :routing do

  describe 'routes' do

    it 'routes GET /treffen/meeting-slug/comments to meetings/comments#index' do
      expect(get: '/treffen/meeting-slug/comments').to route_to(
        controller: 'meetings/comments',
        action: 'index',
        meeting_id: 'meeting-slug')
    end

    it 'routes POST /treffen/meeting-slug/comments to meetings/comments#create' do
      expect(post: '/treffen/meeting-slug/comments').to route_to(
        controller: 'meetings/comments',
        action: 'create',
        meeting_id: 'meeting-slug')
    end

    it 'routes GET /posts/post_id/comments to posts/comments#index' do
      expect(get: '/posts/post_id/comments').to route_to(
        controller: 'posts/comments',
        action: 'index',
        post_id: 'post_id')
    end

    it 'routes POST /posts/post_id/comments to posts/comments#create' do
      expect(post: '/posts/post_id/comments').to route_to(
        controller: 'posts/comments',
        action: 'create',
        post_id: 'post_id')
    end

    it 'routes POST /users/user-slug/comments to users/comments#create' do
      expect(post: '/users/user-slug/comments').to route_to(
        controller: 'users/comments',
        action: 'create',
        user_id: 'user-slug')
    end

    it 'does not route GET /users/user-slug/comments to users/comments#index' do
      expect(get: '/users/user-slug/comments').not_to be_routable
    end

    it 'does not routes PUT /comments/:id to comments#update' do
      expect(put: '/comments/id').not_to be_routable
    end

    it 'routes DELETE /comments/:id to comments#destroy' do
      expect(delete: '/comments/id').to route_to(
        controller: 'comments',
        action: 'destroy',
        id: 'id')
    end
  end

  describe 'named routes' do

    it 'routes POST meeting_comments to meetings/comments#create' do
      expect(post: meeting_comments_path('meeting-slug')).to route_to(
          controller: 'meetings/comments',
          action: 'create',
          meeting_id: 'meeting-slug')
    end

    it 'routes GET meeting_comments to meetings/comments#index' do
      expect(get: meeting_comments_path('meeting-slug')).to route_to(
          controller: 'meetings/comments',
          action: 'index',
          meeting_id: 'meeting-slug')
    end

    it 'routes POST post_comments to post/comments#create' do
      expect(post: post_comments_path('post_id')).to route_to(
          controller: 'posts/comments',
          action: 'create',
          post_id: 'post_id')
    end

    it 'routes GET post_comments to post/comments#index' do
      expect(get: post_comments_path('post_id')).to route_to(
          controller: 'posts/comments',
          action: 'index',
          post_id: 'post_id')
    end

    it 'routes POST user_comments to user/comments#create' do
      expect(post: user_comments_path('user-slug')).to route_to(
          controller: 'users/comments',
          action: 'create',
          user_id: 'user-slug')
    end

    it 'routes DELETE /comments/:id to comments#destroy' do
      expect(delete: comment_path('id')).to route_to(
        controller: 'comments',
        action: 'destroy',
        id: 'id')
    end
  end
end
