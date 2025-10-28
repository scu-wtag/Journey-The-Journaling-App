Rails.application.config.dartsass.builds = {
  'application.scss' => 'application.css',
  'views/sessions/new.scss' => 'views/sessions/new.css',
  'views/users/new.scss' => 'views/users/new.css',
  'views/profiles/show.scss' => 'views/profiles/show.css',
  'views/journals/new.scss' => 'views/journals/new.css',
  'views/journals/show.scss' => 'views/journals/show.css',
  'views/teams/show.scss' => 'views/teams/show.css',
  'views/tasks/new.scss' => 'views/tasks/new.css',
  'views/tasks/form_show.scss' => 'views/tasks/form_show.css',
  'views/tasks/index.scss' => 'views/tasks/index.css',
  'views/tasks/form.scss' => 'views/tasks/form.css',
}

Rails.application.config.dartsass.build_options = [
  '--no-charset', '--embed-sources',
]
