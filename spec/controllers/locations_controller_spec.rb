require 'rails_helper'
include GeojsonSupport

RSpec.describe LocationsController, type: :controller do
  let(:graetzl) { create(:graetzl) }

  describe 'GET address' do
    context 'when authorized user' do
      let(:user) { create(:user_business) }

      before do
        sign_in user
        get :new_address, graetzl_id: graetzl
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'renders address form' do
        expect(response).to render_template(:new_address)
      end
    end

    context 'when unauthorized user' do
      let(:user) { create(:user, role: nil) }

      context 'logged in' do
        before do
          sign_in user
          get :new_address, graetzl_id: graetzl
        end

        it 'redirects to @graetzl' do
          expect(response).to redirect_to graetzl
        end

        it 'shows flash[:error]' do
          expect(flash[:error]).to be_present
        end
      end

      context 'logged out' do
        it 'redirects to login' do
          get :new_address, graetzl_id: graetzl
          expect(response).to render_template(session[:new])
        end
      end
    end
  end

  describe 'POST address' do
    let(:user) { create(:user_business) }

    context 'without :address and :feature' do
      let(:params) { { graetzl_id: graetzl, address: '' } }

      before do
        sign_in user
        post :set_new_address, params
      end

      it 'stores empty address in session' do
        expect(session[:address]).not_to be_nil
        expect(session[:address]).to eq Address.new.attributes
      end

      it 'does not assign new @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns empty @locations' do
        expect(assigns(:locations)).to be_empty
      end

      it 'redirects to new_location in graetzl' do
        expect(response).to redirect_to new_graetzl_location_path(graetzl)
      end
    end

    context 'with empty :feature param' do
      let(:params) { { graetzl_id: graetzl, address: '', feature: '' } }

      before do
        sign_in user
        post :set_new_address, params
      end

      it 'stores empty address in session' do
        expect(session[:address]).not_to be_nil
        expect(session[:address]).to eq Address.new.attributes
      end

      it 'does not assign new @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns empty @locations' do
        expect(assigns(:locations)).to be_empty
      end

      it 'redirects to new_location in graetzl' do
        expect(response).to redirect_to new_graetzl_location_path(graetzl)
      end
    end

    context 'with valid :feature param' do
      let!(:new_graetzl) { create(:graetzl,
        area: 'POLYGON ((0.0 0.0, 0.0 2.0, 2.0 2.0, 2.0 0.0, 0.0 0.0))') }
      let(:address_feature) { feature_hash(1,1) }
      let(:params) {
        { graetzl_id: graetzl,
          address: '', feature: address_feature.to_json } }

      before do
        sign_in user
        post :set_new_address, params
      end

      it 'stores address from feature in session' do
        expect(session[:address]).not_to be_nil
        expect(session[:address]['coordinates'].as_text).to eq 'POINT (1.0 1.0)'
        expect(session[:address]['street_name']).to eq address_feature['properties']['StreetName']
      end

      it 'assigns new @graetzl' do
        expect(assigns(:graetzl)).to eq new_graetzl
      end

      context 'when no locations nearby' do
        it 'assigns empty @locations' do
          expect(assigns(:locations)).to be_empty
        end

        it 'redirects to new_location in new_graetzl' do
          expect(response).to redirect_to new_graetzl_location_path(new_graetzl)
        end
      end

      context 'when basic or managed locations nearby' do
        let!(:basic_location) { create(:location, state: Location.states[:basic],
          address: build(:address, coordinates: 'POINT (1.0005 1.0)'),
          graetzl: new_graetzl) }
        let!(:managed_location) { create(:location, state: Location.states[:managed],
          address: build(:address, coordinates: 'POINT (1.0001 1.0005)'),
          graetzl: new_graetzl) }
        let!(:pending_location) { create(:location, state: Location.states[:pending],
          address: build(:address, coordinates: 'POINT (1.0001 1.0005)'),
          graetzl: new_graetzl) }   
        let!(:other_location) { create(:location, state: Location.states[:basic],
          address: build(:address, coordinates: 'POINT (1.1 1.1)'),
          graetzl: graetzl) }

        before { post :set_new_address, params }

        it 'assigns @locations' do
          expect(assigns(:locations)).not_to be_empty
        end

        describe '@locations' do
          
          it 'contains near basic and managed locations' do
            expect(assigns(:locations)).to include(basic_location, managed_location)
          end

          it 'does not contain outside and pending locations' do
            expect(assigns(:locations)).not_to include(other_location, pending_location)
          end
        end

        it 'renders :adopt' do
          expect(response).to render_template(:adopt)
        end
      end      

      context 'when no locations nearby' do
        let!(:other_location) { create(:location,
          address: build(:address, coordinates: 'POINT (201 201)'),
          graetzl: graetzl) }

        before { post :set_new_address, params }

        it 'assigns empty @locations' do
          expect(assigns(:locations)).to be_empty
        end

        it 'redirects to new_location in new_graetzl' do
          expect(response).to redirect_to new_graetzl_location_path(new_graetzl)
        end
      end
    end
  end

  describe 'GET new' do
    let(:user) { create(:user_business) }

    context 'when no address in session' do
      before do
        sign_in user
        get :new, graetzl_id: graetzl
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end

      describe '@location' do
        subject(:location) { assigns(:location) }

        it 'is not nil' do
          expect(location).not_to be_nil
        end

        it 'has empty address' do
          attrs = Address.new(addressable_type: 'Location').attributes
          expect(location.address.attributes).to eq attrs
        end

        it 'has empty contact' do
          attrs = Contact.new.attributes
          expect(location.contact.attributes).to eq attrs
        end

        # it 'has state :basic' do
        #   expect(location.basic?).to be_truthy
        # end
      end

      it 'renders :new' do
        expect(response).to render_template(:new)
      end
    end

    context 'when address in session' do
      let(:address) { build(:address, addressable_type: 'Location') }

      before do
        sign_in user
        session[:address] = address.attributes
        get :new, graetzl_id: graetzl
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end

      it 'assigns @location with address' do
        expect(assigns(:location).address.attributes).to eq address.attributes
      end
    end
  end

  describe 'POST create' do
    let(:user) { create(:user_business) }

    before { sign_in user }

    it 'empties session' do
      session[:address] = Address.new.attributes
      expect{
        post :create, graetzl_id: graetzl, location: attributes_for(:location)
      }.to change{ session[:address] }.to nil
    end

    context 'with valid attributes' do
      let(:params) {
        {
          graetzl_id: graetzl,
          location: attributes_for(:location).
            merge({ contact_attributes: attributes_for(:contact) }).
            merge({ address_attributes: attributes_for(:address) })
        }
      }

      it 'creates new location record' do
        expect{
          post :create, params
        }.to change(Location, :count).by(1)
      end

      describe 'location' do
        before { post :create, params }
        subject(:new_location) { Location.last }

        it 'has @graetzl' do
          expect(new_location.graetzl).to eq graetzl
        end

        it 'is pending' do
          expect(new_location.pending?).to be_truthy
        end

        it 'has current_user associated' do
          expect(new_location.users).to include(user)
        end
      end

      it 'creates location_ownership' do
        expect{
          post :create, params
        }.to change(LocationOwnership, :count).by(1)        
      end

      it 'redirects to graetzl with notice' do
        post :create, params
        expect(response).to redirect_to graetzl
        expect(flash[:notice]).to be_present
      end
    end
  end

  # describe 'POST create' do
  #   let(:user) { create(:user_business) }

  #   describe 'empty session' do
  #     before do
  #       sign_in user
  #       session[:address] = Address.new.attributes
  #     end

  #     it 'has address in session' do
  #       expect(session[:address]).to be
  #     end

  #     it 'empties session' do
  #       expect{
  #         post :create, graetzl_id: graetzl, location: attributes_for(:location)
  #       }.to change{ session[:address] }.to nil
  #     end
  #   end

  #   context 'with valid attributes' do
  #     let(:attr_basic) { attributes_for(:location) }
  #     let(:attr_contact) { attributes_for(:contact) }
  #     let(:attr_address) { attributes_for(:address) }
  #     let(:params) {{
  #       graetzl_id: graetzl,
  #       location: attr_basic.
  #         merge({ contact_attributes: attr_contact }).
  #         merge({ address_attributes: attr_address })
  #       }}

  #     before { sign_in user }

  #     it 'creates new location' do
  #       expect{
  #         post :create, params
  #       }.to change(Location, :count).by(1)
  #     end

  #     it 'creates new location_onwership' do
  #       expect{
  #         post :create, params
  #       }.to change(LocationOwnership, :count).by(1)
  #     end

      # it 'redirects to graetzl with notice' do
      #   post :create, params
      #   expect(response).to redirect_to graetzl
      #   expect(flash[:notice]).to be_present
      # end

  #     describe 'new location' do
  #       subject(:new_location) { Location.last }

  #       it 'has right attributes' do
  #         post :create, params
  #         expect(new_location).to have_attributes(
  #           name: attr_basic[:name],
  #           slogan: attr_basic[:slogan],
  #           description: attr_basic[:description])
  #       end

  #       it 'has graetzl associated' do
  #         post :create, params
  #         expect(new_location.graetzl).to eq graetzl
  #       end

  #       it 'has state :requested' do
  #         post :create, params
  #         expect(new_location.requested?).to be_truthy
  #       end

  #       it 'has current_user associated' do
  #         post :create, params
  #         expect(new_location.users).to include(user)
  #       end

  #       it 'has new :requested ownership' do
  #         post :create, params
  #         ownership = new_location.location_ownerships.find_by_user_id(user)
  #         expect(ownership.pending?).to be_truthy
  #       end

  #       describe 'address' do
  #         before { post :create, params }

  #         it 'has address' do
  #           expect(new_location.address).to be
  #         end

  #         it 'has right address_attributes' do
  #           expect(new_location.address).to have_attributes(
  #             street_name: attr_address[:street_name],
  #             street_number: attr_address[:street_number],
  #             zip: attr_address[:zip],
  #             city: attr_address[:city])
  #           expect(new_location.address.coordinates.as_text).to eq attr_address[:coordinates]
  #         end
  #       end

  #       describe 'contact' do
  #         before { post :create, params }

  #         it 'has contact' do
  #           expect(new_location.contact).to be
  #         end

  #         it 'has right contact_attributes' do
  #           expect(new_location.contact).to have_attributes(
  #             website: attr_contact[:website],
  #             phone: attr_contact[:phone],
  #             email: attr_contact[:email])
  #         end
  #       end
  #     end
  #   end
  # end

  describe 'GET edit' do
    context 'when basic location' do
      let(:location) { create(:location,
        graetzl: graetzl,
        state: Location.states[:basic]) }

      context 'when non-business user' do
        let(:user) { create(:user, role: nil) }

        before do
          sign_in user
          get :edit, graetzl_id: graetzl, id: location
        end

        it 'redirects to @graetzl with flash[:error] message' do
          expect(response).to redirect_to graetzl
          expect(flash[:error]).to be_present
        end
      end

      context 'when business user' do
        let(:user) { create(:user, role: User.roles[:business]) }

        before do
          sign_in user
          get :edit, graetzl_id: graetzl, id: location
        end

        it 'assigns @graetzl and @location' do
          expect(assigns(:graetzl)).to eq graetzl
          expect(assigns(:location)).to eq location
        end

        it 'renders :edit' do
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'when managed location' do
      let!(:location) { create(:location,
        graetzl: graetzl,
        state: Location.states[:managed]) }

      context 'when business user' do
        let(:user) { create(:user_business) }

        before { sign_in user }

        it 'redirects to @graetzl with flash[:notice]' do
          get :edit, graetzl_id: graetzl, id: location
          expect(response).to redirect_to graetzl
          expect(flash[:notice]).to be_present
        end

        it 'opens ownership_request' do
          pending 'feature not implemented yet'
          fail
          # expect{
          #   get :edit, graetzl_id: graetzl, id: location
          # }.to change(LocationOwnership, :count).by(1)
        end
      end
    end
  end
  #   context 'when basic location' do
  #     let(:location) { create(:location, graetzl: graetzl) }

  #     context 'when user.role non-business' do
  #       let(:user) { create(:user, role: nil) }

  #       before do
  #         sign_in user
  #         get :edit, graetzl_id: graetzl, id: location
  #       end

  #       it 'redirects to @graetzl' do
  #         get :edit, graetzl_id: graetzl, id: location
  #         expect(response).to redirect_to(graetzl)
  #       end

  #       it 'shows error flash message' do
  #         get :edit, graetzl_id: graetzl, id: location
  #         expect(flash[:error]).to be_present
  #       end
  #     end

  #     context 'when user.role :business' do
  #       let(:user) { create(:user_business) }

  #       before do
  #         sign_in user
  #         get :edit, graetzl_id: graetzl, id: location
  #       end

  #       it 'returns a 200 OK status' do
  #         expect(response).to be_success
  #       end

  #       it 'assigns @location' do
  #         expect(assigns(:location)).to eq location
  #       end

  #       it 'assigns @graetzl' do
  #         expect(assigns(:graetzl)).to eq graetzl
  #       end

  #       it 'renders :edit' do
  #         expect(response).to render_template(:edit)
  #       end
  #     end
  #   end

  #   context 'when managed location' do
  #     let(:location) { create(:location, state: Location.states[:managed], graetzl: graetzl) }
  #     let(:user) { create(:user_business) }

  #     before do
  #       sign_in user
  #       get :edit, graetzl_id: graetzl, id: location
  #     end

  #     it 'redirects to @graetzl page' do
  #       expect(response).to redirect_to(graetzl)
  #     end

  #     it 'shows flash notice' do
  #       expect(flash[:notice]).to be_present
  #     end
  #   end

  #   context 'when pending location' do
  #     let(:location) { create(:location, state: Location.states[:managed], graetzl: graetzl) }
  #     let(:user) { create(:user_business) }

  #     before do
  #       sign_in user
  #       get :edit, graetzl_id: graetzl, id: location
  #     end

  #     it 'redirects to @graetzl page' do
  #       expect(response).to redirect_to(graetzl)
  #     end

  #     it 'shows flash notice' do
  #       expect(flash[:notice]).to be_present
  #     end
  #   end

  #   context 'when requested location' do
  #     let(:location) { create(:location, state: Location.states[:managed], graetzl: graetzl) }
  #     let(:user) { create(:user_business) }

  #     before do
  #       sign_in user
  #       get :edit, graetzl_id: graetzl, id: location
  #     end

  #     it 'redirects to @graetzl page' do
  #       expect(response).to redirect_to(graetzl)
  #     end

  #     it 'shows flash notice' do
  #       expect(flash[:notice]).to be_present
  #     end
  #   end
  # end

  describe 'PUT update' do
    context 'when basic location' do
      let(:location) { create(:location,
        graetzl: graetzl,
        state: Location.states[:basic]) }
      let(:user) { create(:user_business) }
      let(:params) {
        {
          graetzl_id: graetzl,
          id: location,
          location: attributes_for(:location)
        }
      }

      before { sign_in user }

      it 'assigns @graetzl and @location' do
        put :update, params
        expect(assigns(:graetzl)).to eq graetzl
        expect(assigns(:location)).to eq location
      end

      it 'updates state to pending' do
        expect{
          put :update, params
        }.to change{location.reload.state}.to 'pending'
      end

      it 'adds current_user to users' do
        put :update, params
        expect(assigns(:location).users).to include(user)
      end

      it 'redirects to @graetzl with flash[:notice]' do
        put :update, params
        expect(response).to redirect_to graetzl
        expect(flash[:notice]).to be_present
      end
    end
  end
end
