desc "This task is called by the Heroku scheduler add-on"
task :scrape => :environment do

  #UPDATE DATA
  Case.all.each {|kase| kase.update_data}

  #EMAIL USERS
  User.all.each do |user|
########## scrape lacourt.org for each case in DB
    #scan_for_new_criminal_data(user)

    new_documents = user.documents.select(&:needs_email)
    new_hearings = user.hearings.select(&:needs_email)

########## send the new docuemnts in an email... and mark needs_email false
    
    byebug
    unless new_documents.empty? && new_hearings.empty?
      ( new_hearings + new_documents ).each {|item| item.needs_email=false; item.save}

      UpdateMailer.test_email(user, new_documents, new_hearings).deliver
    end
  end

end

def scan_for_new_criminal_data(user)
  require 'rubygems'
  require 'mechanize'
  require 'nokogiri'

  user.cases.select{|kase| kase.case_type==CaseType.find_by_title("Criminal")}.each do |kase|
    mechanize = Mechanize.new

    ########## FORM FILL

    page = mechanize.get('http://www.lacourt.org/criminalcasesummary/ui/')
    page = mechanize.submit(page.forms.last)

    page.forms.last.fields[3].value = kase.uid

    page = mechanize.submit(page.forms.last)

    ########## SCAN FOR INFO

    noko = Nokogiri::HTML(page.body)

    events_table = noko.at('#siteMasterHolder_basicBodyHolder_TabControls_EventsInfo_tabCaseList')
    events_table.children.select{|row| row.name=="tr" && row.children.map(&:name).include?("td") }.each do |row|
      ##### loop through the event rows

      columns = row.children.select{|el| el.name == "td"}.map(&:text)
      hearing = Hearing.new

      date = Date.parse columns[0]
      time = Time.parse columns[1]
      location = columns[2] + " ("+ columns[3] + ")"
      title = columns[4]

      hearing.title = title
      hearing.location = location
      hearing.time = Time.new(date.year, date.month, date.day, time.hour, time.min)
      hearing.case = kase

      #check for match
      matches = Hearing.where(time: hearing.time).where(location: hearing.location).where(case_id: hearing.case.id)
      if matches.empty? || !matches.map(&:case).map(&:user).include?(user)
        hearing.needs_email = true
        hearing.save
      end

    end
  end
end
