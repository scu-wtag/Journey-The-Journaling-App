Rails.application.config.dartsass.builds = {
  'application.scss' => 'application.css',
  'views/sessions/new.scss' => 'views/sessions/new.css',
  'views/users/new.scss' => 'views/users/new.css',
  'views/profiles/show.scss' => 'views/profiles/show.css'
}

Rails.application.config.dartsass.build_options = [
  '--no-charset', '--embed-sources',
]
