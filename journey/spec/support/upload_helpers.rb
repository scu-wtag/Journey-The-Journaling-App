module UploadHelpers
  def upload(path, mime)
    Rack::Test::UploadedFile.new(Rails.root.join(path), mime)
  end
end

RSpec.configure do |c|
  c.include UploadHelpers, type: :request
end
