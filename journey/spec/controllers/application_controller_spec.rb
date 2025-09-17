require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'ok'
    end
  end

  before do
    routes.draw { get 'anonymous' => 'anonymous#index' }
    allow(I18n).to receive(:available_locales).and_return(%i(en de))
    I18n.default_locale = :en
  end

  it 'sets locale from valid params[:locale]' do
    get :index, params: { locale: 'de' }
    expect(I18n.locale).to eq(:de)
  end

  it 'falls back to default for invalid locale' do
    get :index, params: { locale: 'fr' }
    expect(I18n.locale).to eq(:en)
  end

  it 'injects locale into default_url_options' do
    get :index, params: { locale: 'de' }
    expect(controller.__send__(:default_url_options)[:locale]).to eq(:de)
  end
end
