require 'rails_helper'

RSpec.describe HomeController do
  it 'renders when signed in' do
    user = create(:user)
    allow(controller).to receive_messages(signed_in?: true, current_user: user)

    get :show, params: { locale: :en }
    expect(response).to have_http_status(:ok)
  end
end
