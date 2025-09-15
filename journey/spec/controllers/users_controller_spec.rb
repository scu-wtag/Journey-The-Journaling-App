require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before do
    allow(I18n).to receive(:available_locales).and_return(%i(en de))
    I18n.default_locale = :en
  end

  describe 'GET #new' do
    it 'redirects to root when signed in' do
      user = create(:user)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:signed_in?).and_return(true)

      get :new, params: { locale: I18n.locale }
      expect(response).to redirect_to(root_path(locale: I18n.locale))
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          email: 'new@example.com',
          name: 'New Name',
          password: 'password123',
          password_confirmation: 'password123',
          profile_attributes: {
            phone_country_code: '41',
            phone_local: '79 123 45 67',
            birthday: '2000-01-01',
            country: 'CH',
            headquarters: 'Zurich',
          },
        },
      }
    end

    it 'redirects to root when already signed in' do
      user = create(:user)
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:signed_in?).and_return(true)

      expect do
        post :create, params: valid_params.merge(locale: I18n.locale)
      end.not_to change(User, :count)

      expect(response).to redirect_to(root_path(locale: I18n.locale))
    end
  end
end
