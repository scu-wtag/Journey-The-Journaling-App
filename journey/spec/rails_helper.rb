require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }
RSpec.configure(&:infer_spec_type_from_file_location!)

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => error
  abort error.to_s.strip
end

require 'factory_bot_rails'
require 'shoulda-matchers'
require 'clearance/rspec'

Shoulda::Matchers.configure do |c|
  c.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

module AuthHelpers
  def sign_in(user)
    cookies[Clearance.configuration.cookie_name] = user.remember_token
  end

  def sign_in_as(user)
    sign_in(user)
  end

  def sign_out
    cookies.delete(Clearance.configuration.cookie_name)
  end
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include AuthHelpers, type: :request
  config.infer_spec_type_from_file_location!
  config.after(:suite) do
    service = ActiveStorage::Blob.service
    FileUtils.rm_rf(service.root) if service.respond_to?(:root) && service.root.present?
  end
end
