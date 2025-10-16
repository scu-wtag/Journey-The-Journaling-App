require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  it 'renders when signed in' do
    user = create(:user)
    allow(controller).to receive(:signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)

    get :show, params: { locale: :en }
    expect(response).to have_http_status(:ok)
  end
end
