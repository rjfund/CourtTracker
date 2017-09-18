desc "This task is called by the Heroku scheduler add-on"
task :scrape => :environment do

  User.all.each do |user|
    scan_for_new_data(user)

    new_documents = user.documents.select(&:needs_email)
    new_hearings = user.hearings.select(&:needs_email)

    unless new_documents.empty? && new_hearings.empty?
      # send the new docuemnts in an email...
      new_documents.each do |doc|
        doc.needs_email = false
        doc.save
      end

      new_hearings.each do |hearing|
        hearing.needs_email = false
        hearing.save
      end

      UpdateMailer.test_email(user, new_documents, new_hearings).deliver
    end
  end

end

def scan_for_new_data(user)
  user.cases.each do |kase|

    require 'rubygems'
    require 'mechanize'
    require 'nokogiri'

    mechanize = Mechanize.new

    page = mechanize.get('http://www.lacourt.org/casesummary/ui/index.aspx?casetype=civil')

    test_case_number = kase.uid

    case_number_field = page.search("input.textInput")[0]

    form = page.forms.last
    form.field_with(:name=> "CaseNumber").value = test_case_number

    page = mechanize.submit(form)

    noko = Nokogiri::HTML(page.body)

    el = noko.at('span.contentSubHeading:contains("Future Hearings")')

    #get future hearings
    run = !el.nil?
    while run
      el = el.next

      if el.name == 'b'
        text = el.text + el.next.text

        parsed_event = Nickel.parse text
        sd= parsed_event.occurrences.first.start_date
        st= parsed_event.occurrences.first.start_time

        hearing = Hearing.new
        hearing.time = Time.new(sd.year, sd.month, sd.day, st.hour, st.minute)
        hearing.title = parsed_event.message

        hearing.case = kase

        #check if hearing is already in DB
        match = Hearing.where(time: hearing.time).where(title: hearing.title).where(case_id: hearing.case.id)

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

