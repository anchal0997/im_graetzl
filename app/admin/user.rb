ActiveAdmin.register User do
  include ViewInApp
  menu priority: 3
  includes :graetzl

  scope :all, default: true
  scope :business
  scope :admin

  filter :graetzl
  filter :username
  filter :first_name
  filter :last_name
  filter :email
  filter :role, as: :select, collection: User.roles.keys
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :graetzl_id,
    :username,
    :first_name,
    :last_name,
    :email,
    :password,
    :newsletter,
    :bio,
    :website,
    :avatar, :remove_avatar,
    :cover_photo, :remove_cover_photo,
    :role,
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :description,
      :coordinates]

    csv do
      column :id
      column :email
      column :username
      column(:profile_url) { |user| Rails.application.routes.url_helpers.user_path(user) }
      column :first_name
      column :last_name
      column(:graetzl) { |user| user.graetzl.name }
      column(:graetzl_url) { |user| Rails.application.routes.url_helpers.graetzl_path(user.graetzl) }
      column(:post_count) { |user| user.posts.count }
      column :last_sign_in_at
      column :created_at
      column :confirmed_at
      column :role
      column :slug
      column :website
      column :newsletter
      column(:bezirk_1) { |user| user.graetzl.districts.first.try(:zip) }
      column(:bezirk_2) { |user| user.graetzl.districts.second.try(:zip) }
      column(:location_1) { |user| user.primary_location.try(:name) }
      column(:location_1_url) { |user|
        Rails.application.routes.url_helpers.location_path(user.primary_location) if user.locations.present?
      }
      column(:location_1_bezirk) { |user|
        location = user.primary_location
        location.graetzl.districts.first.try(:zip)
      }
      column(:location_1_graetzl) { |user|
        location = user.primary_location
        location.graetzl.name
      }
      column(:location_1_graetzl_url) { |user|
        location = user.primary_location
        Rails.application.routes.url_helpers.graetzl_path(location.graetzl)
      }
      column(:location_1_category) { |user|
        location = user.primary_location
        location.category.name
      }
      column(:meetings_initiated) { |user| user.going_tos.initiator.count }
      column(:location_posts) { |user| user.location_posts.count }
    end
end
