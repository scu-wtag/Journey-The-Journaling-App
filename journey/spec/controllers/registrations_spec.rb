require 'rails_helper'

RSpec.describe RegistrationsController, type: :request do
  it 'creates a user' do
    post registrations_path, params: { user: { email: 'a@b.ch', password: 'secret123', name: 'Test' } }
    expect(User.count).to eq(1)
  end

  describe 'GET /registrations/new' do
    it 'returns http success' do
      get new_registration_path
      expect(response).to have_http_status(:success)
    end
  end
end
