require 'rails_helper'

RSpec.describe Admin::GraetzlsController, type: :controller do
  let(:admin) { create(:user, role: User.roles[:admin]) }

  before { sign_in admin }

  describe 'GET index' do
    before { get :index }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @graetzls' do
      expect(assigns(:graetzls)).not_to be_nil
    end

    it 'renders :index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    let!(:graetzl) { create(:graetzl) }
    before { get :show, id: graetzl }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq graetzl
    end

    it 'renders :show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to be_a_new(Graetzl)
    end

    it 'renders :new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:graetzl) { build(:graetzl) }
    let(:params) {
      {
        graetzl: {
          name: graetzl.name,
          state: graetzl.state,
          area: graetzl.area
        }
      }
    }

    it 'creates new graetzl record' do
      expect{
        post :create, params
      }.to change{Graetzl.count}.by(1)
    end

    it 'assigns attributes to graetzl' do
      post :create, params
      g = Graetzl.last
      expect(g).to have_attributes(
        name: graetzl.name,
        state: graetzl.state,
        area: graetzl.area)
    end

    it 'redirects_to new graetzl page' do
      post :create, params
      new_graetzl = Graetzl.last
      expect(response).to redirect_to(admin_graetzl_path(new_graetzl))
    end
  end

  describe 'GET edit' do
    let(:graetzl) { create(:graetzl) }
    before { get :edit, id: graetzl }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq graetzl
    end

    it 'renders :edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    let(:graetzl) { create(:graetzl) }
    let(:new_graetzl) { build(:graetzl) }
    let(:params) {
      {
        id: graetzl,
        graetzl: {
          name: new_graetzl.name,
          state: new_graetzl.state,
          area: new_graetzl.area
        }
      }
    }

    before do
      patch :update, params
      graetzl.reload
    end

    it 'redirects to graetzl page' do
      expect(response).to redirect_to(admin_graetzl_path(graetzl))
    end

    it 'updates graetzl attributes' do
      expect(graetzl).to have_attributes(
        name: new_graetzl.name,
        state: new_graetzl.state,
        area: new_graetzl.area)
    end
  end

  describe 'DELETE destroy' do
    let!(:graetzl) { create(:graetzl) }

    it 'deletes graetzl record' do
      expect{
        delete :destroy, id: graetzl
      }.to change{Graetzl.count}.by(-1)
    end

    it 'redirects_to index page' do
      delete :destroy, id: graetzl
      expect(response).to redirect_to(admin_graetzls_path)
    end
  end
end