require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def index
      head :ok
    end
  end

  before do
    routes.draw do
      get 'anonymous' => 'anonymous#index'
    end
  end

  it 'sets locale from valid params[:locale]' do
    allow(controller).to receive(:signed_in?).and_return(false)

    get :index, params: { locale: 'de' }
    expect(I18n.locale.to_s).to eq('de')
  end

  it 'falls back to default for invalid locale' do
    allow(controller).to receive(:signed_in?).and_return(false)

    get :index, params: { locale: 'xx' }
    expect(I18n.locale.to_s).to eq(I18n.default_locale.to_s)
  end
end
