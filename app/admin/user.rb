ActiveAdmin.register User do
  include ViewInApp
  menu priority: 3
  includes :graetzl, :wall_comments, :posts, :meetings, :locations

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
  filter :updated_at

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
    :avatar,
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :description,
      :coordinates]
end
