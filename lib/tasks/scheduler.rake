desc "This task is called by the Heroku scheduler add-on"
task :scrape => :environment do
  UpdateMailer.test_email.deliver
end
