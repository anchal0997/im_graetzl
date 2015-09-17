require 'rails_helper'

RSpec.describe DistrictsController, type: :routing do
  
  describe 'routes' do

    it 'routes GET /wien to districts#index' do
      expect(get: '/wien').to route_to('districts#index')
    end

    it 'routes GET /wien/district-slug to districts#show' do
      expect(get: '/wien/district-slug').to route_to('districts#show', id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/graetzlzuckerl to zuckerls#index' do      
      expect(get: '/wien/district-slug/graetzlzuckerl').to route_to(
        controller: 'zuckerls',
        action: 'index',
        id: 'district-slug')
    end
  end


  describe 'named routes' do

    it 'routes GET districts_path) to districts#index' do
      expect(get: districts_path).to route_to(
        controller: 'districts',
        action: 'index')
    end

    it 'routes GET district_path(district-slug) to districts#show' do
      expect(get: district_path('district-slug')).to route_to(
        controller: 'districts',
        action: 'show',
        id: 'district-slug')
    end

    it 'routes GET zuckerl_district_path(district-slug) to zuckerls#index' do
      expect(get: zuckerl_district_path('district-slug')).to route_to(
        controller: 'zuckerls',
        action: 'index',
        id: 'district-slug')
    end
  end
end