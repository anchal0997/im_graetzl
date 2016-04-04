# Use this file to easily define all of your cron jobs.

set :environment, ENV['RACK_ENV']

every 1.day, at: '0:00 am' do
  command "cd #{path} && #{environment_variable}=#{ENV['RACK_ENV']} #{bundle_command} rake db:truncate"
end

every 1.day, at: '1:00 am' do
  command "cd #{path} && #{environment_variable}=#{ENV['RACK_ENV']} #{bundle_command} rake sitemap:refresh:no_ping"
end

every 1.day, at: '2:00 am' do
  command "cd #{path} && #{environment_variable}=#{ENV['RACK_ENV']} #{bundle_command} rake db:backup"
end

every 1.day, at: '5:15 am' do
  command "cd #{path} && #{environment_variable}=#{ENV['RACK_ENV']} #{bundle_command} rake daily_mail"
end
