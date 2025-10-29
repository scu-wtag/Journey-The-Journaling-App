require 'base64'

RSpec.configure do |config|
  config.before(:suite) do
    base = Rails.root.join('spec/fixtures/files')
    FileUtils.mkdir_p(base)

    txt = base.join('test.txt')
    File.write(txt, "hello\n") unless File.exist?(txt)

    png = base.join('test.png')
    unless File.exist?(png)
      data = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII='
      File.binwrite(png, Base64.decode64(data))
    end
  end
end
