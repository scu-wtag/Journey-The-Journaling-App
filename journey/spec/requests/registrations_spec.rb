require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  it 'creates a user' do
    post registrations_path, params: { user: { email: 'a@b.ch', password: 'secret123', name: 'Test' } }
    expect(User.count).to eq(1)
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/registrations/create'
      expect(response).to have_http_status(:success)
    end
  end
end
