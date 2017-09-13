desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  Case.destroy_all
end
