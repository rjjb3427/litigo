Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_assets  = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :cache
  config.action_mailer.cache_settings = { :location => "#{Rails.root}/tmp/mail.cache" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Adding this because tests bomb out if I don't have it :(
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.active_record.raise_in_transactional_callbacks = true
  ENV['PUBLISHABLE_KEY'] = 'pk_test_bdNUNhdPuw421zThmcq5qAmA'
  ENV['SECRET_KEY'] = 'sk_test_sUhYz929KV8ZvJ1rvesMzyBp'
  ENV['EXPIRE_HOURS'] = '8'
  ENV['S3_KEY'] = 'TEST'
  ENV['S3_SECRET'] = 'TEST'
  ENV['S3_BUCKET_NAME'] = 'TEST'
end
