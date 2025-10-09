require 'rails_helper'

RSpec.describe UsersController do
  before do
    allow(I18n).to receive(:available_locales).and_return(%i(en de))
    I18n.default_locale = :en
  end

  describe 'GET #new' do
    it 'redirects to root when signed in' do
      user = create(:user)
      allow(controller).to receive_messages(current_user: user, signed_in?: true)

      get :new, params: { locale: I18n.locale }
      expect(response).to redirect_to(root_path(locale: I18n.default_locale))
    end
  end
end
