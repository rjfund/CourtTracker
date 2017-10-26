desc "This task is called by the Heroku scheduler add-on"
task :scrape => :environment do

  User.all.each do |user|
########## scrape lacourt.org for each case in DB
    scan_for_new_civil_data(user)
    scan_for_new_criminal_data(user)

    new_documents = user.documents.select(&:needs_email)
    new_hearings = user.hearings.select(&:needs_email)

########## send the new docuemnts in an email... and mark needs_email false
    
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

def scan_for_new_civil_data(user)
  require 'rubygems'
  require 'mechanize'
  require 'nokogiri'

  user.cases.select{|kase| kase.case_type==CaseType.find_by_title("Civil")}.each do |kase|

    mechanize = Mechanize.new

########## FORM FILL
    
    page = mechanize.get('http://www.lacourt.org/casesummary/ui/index.aspx?casetype=civil')

    test_case_number = kase.uid

    form = page.forms.last
    form.field_with(:name=> "CaseNumber").value = test_case_number


    page = mechanize.submit(form)

######### START SCANNING

    noko = Nokogiri::HTML(page.body)

######### future hearings
    
    el = noko.at('span.contentSubHeading:contains("Future Hearings")')
    run = !el.nil?
    while run
      el = el.next

      if el.name == 'b'
        text = el.text + el.next.text

        parsed_event = Nickel.parse text
        sd= parsed_event.occurrences.first.start_date
        st= parsed_event.occurrences.first.start_time

        hearing = Hearing.new
        hearing.time = Time.new(sd.year, sd.month, sd.day, st.hour, st.min)
        hearing.location = parsed_event.message

        hearing.case = kase

        #check if hearing is already in DB
        match = Hearing.where(time: hearing.time).where(location: hearing.location).where(case_id: hearing.case.id)

        # if it's not already in there add it to the database and flag it for email
        if match.empty?
          hearing.needs_email = true
          hearing.save
        end

      end

      if el.attr('class') && el.attr('class')=="dividerGrayLine"
        run = false
      end
    end

######### documents filed
    
    el = noko.at('span.contentSubHeading:contains("Documents Filed")')
    run = !el.nil?
    while run
      if el.name == "p"
        #month/day/year, text, filed by
        matches = el.text.match /(\d{2})\/(\d{2})\/([0-9]{4})\s(.*)Filed\sby\s(.*)/
        unless matches.nil?

          date = "#{ matches[2] }/#{matches[1]}/#{matches[3]}"
          title = matches[4]
          filed_by = matches[5]

          document = Document.new
          document.date = date
          document.title = title
          document.filed_by = filed_by
          document.case = kase

          #check if document is already in DB
          match = Document.where(date: document.date).where(title: document.title).where(filed_by: document.filed_by).where(case_id: document.case.id)

          # if it's not already in there add it to the database and flag it for email
          if match.empty?
            document.needs_email = true
            document.save
          end

        end
      end

      el = el.next
      if el.attr('class') && el.attr('class')=="dividerGrayLine"
        run = false
      end
    end
  end
end

desc "test out the crim scraping..."
task :crim_scrape => :environment do
  require 'rubygems'
  require 'mechanize'
  require 'nokogiri'

  mechanize = Mechanize.new

  ########## FORM FILL

  page = mechanize.get('http://www.lacourt.org/criminalcasesummary/ui/')
  page = mechanize.submit(page.forms.last)

  page.forms.last.fields[3].value = "BA342574"

  page = mechanize.submit(page.forms.last)

  ########## SCAN FOR INFO
  
  noko = Nokogiri::HTML(page.body)

  defendant_name = noko.at('td:contains("Defendant Name")').next.text.strip

  events_table = noko.at('#siteMasterHolder_basicBodyHolder_TabControls_EventsInfo_tabCaseList')
  hearings = []
  events_table.children.select{|row| row.name=="tr" && row.children.map(&:name).include?("td") }.each do |row|
    ##### loop through the event rows

    columns = row.children.select{|el| el.name == "td"}.map(&:text)
    new_hearing = Hearing.new

    date = Date.parse columns[0]
    time = Time.parse columns[1]
    location = columns[2] + " ("+ columns[3] + ")"
    title = columns[4]

    new_hearing.title = title
    new_hearing.location = location
    new_hearing.time = Time.new(date.year, date.month, date.day, time.hour, time.min)
  end
end

desc "Fix location title issue"
task :fix_location_title_data => :environment do
  Hearing.all.each do |hearing|
    hearing.location = hearing.title
    hearing.title=nil
    hearing.save
  end
end
