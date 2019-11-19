require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/cron/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ['admin', ENV['SIDEKIQ_PASSWORD']]
end

Sidekiq.configure_server do |config|
  config.average_scheduled_poll_interval = 2
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/12', namespace: 'TESTDOCKERPROJECT' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/12', namespace: 'TESTDOCKERPROJECT' }
end

schedule_file = 'config/schedule.yml'
if File.exists?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
