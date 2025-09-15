# spec/requests/users_request_spec.rb
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:redirect_url) { '/dashboard' }

  before do
    allow(Clearance.configuration).to receive(:redirect_url).and_return(redirect_url)
  end

  describe 'GET /signup' do
    it 'renders new when signed out' do
      get sign_up_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /users' do
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

    it 'creates a user and redirects with notice' do
      expect do
        post users_path, params: valid_params
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(redirect_url)
      follow_redirect!

      user = User.find_by(email: 'new@example.com')
      expect(user).to be_present
      expect(user.profile.phone).to eq('+41791234567')
    end

    it 'adds mismatch error and re-renders when confirmation differs' do
      params = valid_params.deep_merge(user: { password_confirmation: 'WRONG' })

      expect do
        post users_path, params: params
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('password')
    end

    it 're-renders with unprocessable_content when validations fail' do
      bad = valid_params.deep_merge(user: { email: '' })

      expect do
        post users_path, params: bad
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
