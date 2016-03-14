require 'rails_helper'

RSpec.describe DistrictsController, type: :routing do

  describe 'routes' do
    it 'routes GET /wien to districts#index' do
      expect(get: '/wien').to route_to('districts#index')
    end

    it 'routes GET /wien/district-slug to districts#show' do
      expect(get: '/wien/district-slug').to route_to('districts#show', id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/graetzls to districts#graetzls' do
      expect(get: '/wien/district-slug/graetzls').to route_to('districts#graetzls', id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/graetzlzuckerl to districts/zuckerls#index' do
      expect(get: '/wien/district-slug/graetzlzuckerl').to route_to('districts/zuckerls#index', district_id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/locations to districts/locations#index' do
      expect(get: '/wien/district-slug/locations').to route_to('districts/locations#index', district_id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/treffen to districts/meetings#index' do
      expect(get: '/wien/district-slug/treffen').to route_to('districts/meetings#index', district_id: 'district-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET districts_path to districts#index' do
      expect(get: districts_path).to route_to('districts#index')
    end

    it 'routes GET district_path to districts#show' do
      expect(get: district_path('district-slug')).to route_to('districts#show', id: 'district-slug')
    end

    it 'routes GET district_zuckerls_path to districts/zuckerls#index' do
      expect(get: district_zuckerls_path('district-slug')).to route_to('districts/zuckerls#index', district_id: 'district-slug')
    end

    it 'routes GET district_locations_path to districts/locations#index' do
      expect(get: district_locations_path('district-slug')).to route_to('districts/locations#index', district_id: 'district-slug')
    end

    it 'routes GET district_meetings_path to districts/meetings#index' do
      expect(get: district_meetings_path('district-slug')).to route_to('districts/meetings#index', district_id: 'district-slug')
    end
  end
end
