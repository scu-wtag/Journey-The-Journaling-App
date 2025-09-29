require 'rails_helper'
require 'base64'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user, locale: 'en', theme: 'light') }
  let(:profile) { user.profile }

  describe 'GET /profile' do
    it 'renders show for signed-in user and ensures profile exists' do
      expect(user.profile).to be_nil

      sign_in(user)
      get profile_path(locale: :en)

      expect(response).to have_http_status(:ok)
      expect(user.reload.profile).to be_present
      expect(user.profile).to be_persisted
    end
  end

  describe 'PATCH /profile (JSON)' do
    before { sign_in(user) }

    it 'updates user locale and sets cookie, returns 204' do
      patch profile_path(locale: :en),
            params: { user: { locale: 'de' } }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:no_content)
      expect(user.reload.locale).to eq('de')
      expect(cookies[:locale]).to eq('de')
    end

    it 'updates user theme and sets cookie, returns 204' do
      patch profile_path(locale: :en),
            params: { user: { theme: 'dark' } }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:no_content)
      expect(user.reload.theme).to eq('dark')
      expect(cookies[:theme]).to eq('dark')
    end

    it 'updates profile attributes (country, HQ)' do
      patch profile_path(locale: :en),
            params: { profile: { country: 'DE', headquarters: 'Berlin' } }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:no_content)
      expect(profile.reload.country).to eq('DE')
      expect(profile.headquarters).to eq('Berlin')
    end

    it 'applies phone parts and composes phone' do
      patch profile_path(locale: :en),
            params: { profile: { phone_country_code: '41', phone_local: '79 123 45 67' } }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:no_content)
      expect(profile.reload.phone).to eq('+41791234567')
    end

    it 'returns 422 on invalid user update' do
      patch profile_path(locale: :en),
            params: { user: { email: '' } }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      expect(body).to include('error' => 'invalid')
    end
  end

  describe 'PATCH /profile (HTML)' do
    before { sign_in(user) }

    it 'redirects with notice on success (i18n key must exist)' do
      patch profile_path(locale: :en), params: {
        user: { locale: 'de' }, profile: { country: 'AT' },
      }
      expect(response).to redirect_to(profile_path(locale: :en))
      follow_redirect!
      expect(flash[:notice]).to be_present
    end
  end

  describe 'avatar upload' do
    before { sign_in(user) }

    it 'attaches a picture via multipart form' do
      png_data = Base64.decode64(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
      )
      tmp = Tempfile.new(['avatar', '.png'])
      tmp.binmode
      tmp.write(png_data)
      tmp.rewind

      file = Rack::Test::UploadedFile.new(tmp.path, 'image/png')
      patch profile_path(locale: :en), params: { profile: { picture: file } }

      expect(response).to redirect_to(profile_path(locale: :en))
      expect(user.reload.profile.picture).to be_attached
    ensure
      tmp.close!
    end
  end
end
