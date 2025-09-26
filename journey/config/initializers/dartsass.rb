Rails.application.config.dartsass.builds = {
  'application.scss' => 'application.css',
  'views/sessions/new.scss' => 'views/sessions/new.css',
}

Rails.application.config.dartsass.build_options = [
  '--no-charset', '--embed-sources',
]
