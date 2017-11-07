class RoomsController < ApplicationController

  def index
    room_offers = room_offers_scope.includes(:user, :graetzl, :district)
    room_offers = filter_offers(room_offers)
    room_offers = room_offers.page(params[:page]).per(15)

    room_demands = room_demands_scope.includes(:user, :graetzls, :districts)
    room_demands = filter_demands(room_demands)
    room_demands = room_demands.page(params[:page]).per(15)

    @rooms = room_offers + room_demands
    @next_page = room_offers.next_page.present? || room_demands.next_page.present?
  end

  private

  def room_offers_scope
    if params[:district_id].present?
      RoomOffer.where(district_id: params[:district_id])
    else
      RoomOffer.all
    end
  end

  def room_demands_scope
    if params[:district_id].present?
      district = District.find(params[:district_id])
      RoomDemand.includes(:graetzls).where(graetzls: {id: district.graetzl_ids})
    else
      RoomDemand.all
    end
  end

  def filter_offers(offers)
    room_type = params.dig(:filter, :room_type)
    if room_type.present?
      action_type, offer_type = room_type.split("-")
      if action_type == 'demand'
        return RoomOffer.none
      elsif offer_type.present?
        offers = offers.where(offer_type: offer_type)
      end
    end

    room_category_ids = params.dig(:filter, :room_category_ids)
    if room_category_ids.present? && room_category_ids.any?(&:present?)
      offers = offers.joins(:room_categories).where(room_categories: {id: room_category_ids})
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)
    if graetzl_ids.present? && graetzl_ids.any?(&:present?)
      offers = offers.where(graetzl_id: graetzl_ids)
    end

    offers
  end

  def filter_demands(demands)
    room_type = params.dig(:filter, :room_type)
    if room_type.present?
      action_type, demand_type = room_type.split("-")
      if action_type == 'offer'
        return RoomDemand.none
      elsif demand_type.present?
        demands = demands.where(demand_type: demand_type)
      end
    end

    room_category_ids = params.dig(:filter, :room_category_ids)
    if room_category_ids.present? && room_category_ids.any?(&:present?)
      demands = demands.joins(:room_categories).where(room_categories: {id: room_category_ids})
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)
    if graetzl_ids.present? && graetzl_ids.any?(&:present?)
      demands = demands.includes(:graetzls).where(graetzls: {id: graetzl_ids})
    end

    demands
  end

end
