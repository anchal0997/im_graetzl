ActiveAdmin.register Location do
  include SharedAdmin
  menu priority: 3

  scope :all, default: true
  scope :basic
  scope :pending
  scope :managed

  # index
  index do
    render 'index', context: self
  end

  # filter
  filter :graetzl
  filter :name
  filter :slogan
  filter :description
  filter :state, as: :select, collection: Location.states.keys
  filter :users
  filter :created_at
  filter :updated_at

  # show
  show do
    render 'show', context: self
  end

  # form
  form partial: 'form'

  # controller actions
  collection_action :new_from_address, method: :post do
    address = Address.find(params[:address])
    @location = Location.new(name: address.description,
      state: 'basic',
      graetzl: address.graetzl,
      contact: Contact.new)
    @location.build_address(street_name: address.street_name,
      street_number: address.street_number,
      zip: address.zip,
      city: address.city,
      coordinates: address.coordinates)
  end


  # batch actions
  batch_action :approve do |ids|
    batch_action_collection.find(ids).each do |location|
      location.approve
    end
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden freigeschalten.'
  end

  batch_action :reject, confirm: 'Wirklich alle ablehnen?' do |ids|
    batch_action_collection.find(ids).each do |location|
      location.reject
    end
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden abgelehnt.'
  end


  # action buttons
  action_item :approve, only: :show, if: proc{ location.pending? } do
    link_to 'Location Freischalten', approve_admin_location_path(location), { method: :put }
  end

  action_item :reject, only: :show, if: proc{ location.pending? } do
    link_to 'Location Ablehnen', reject_admin_location_path(location), { method: :put }
  end


  # member actions
  member_action :approve, method: :put do
    if resource.approve
      flash[:success] = 'Location wurde freigeschalten.'
      redirect_to admin_locations_path
    else
      flash[:error] = 'Location kann nicht freigeschalten werden.'
      redirect_to resource_path
    end
  end

  member_action :reject, method: :put do
    if resource.reject
      flash[:notice] = 'Location wurde abgelehnt.'
      redirect_to admin_locations_path
    else
      flash[:error] = 'Location kann nicht abgelehnt werden.'
      redirect_to resource_path
    end
  end


  # strong parameters
  permit_params :graetzl_id,
    :state,
    :name,
    :slug,
    :slogan,
    :description,
    :avatar, :remove_avatar,
    :cover_photo, :remove_cover_photo,
    contact_attributes: [
      :id,
      :website,
      :email,
      :phone],
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :coordinates,
      :description],
    location_ownerships_attributes: [
      :id,
      :user_id,
      :state,
      :_destroy]
end
