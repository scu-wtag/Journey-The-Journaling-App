require 'rails_helper'

RSpec.describe 'Home', type: :request do
  it 'renders a page (root or show) without error' do
    # Pick the route your app actually has. If root is set to Home#show:
    get root_path
    expect(response).to have_http_status(:ok).or have_http_status(:success)
  end
end
