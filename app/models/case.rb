class Case < ApplicationRecord
  belongs_to :user
  belongs_to :case_type
  has_many :documents, dependent: :destroy
  has_many :hearings, dependent: :destroy
  attr_accessor :name


  before_create :scrape_data, :check_check

  def scrape_data
    if self.case_type == CaseType.find_by_title("Civil")
      res = scrape_civil_data
    elsif self.case_type == CaseType.find_by_title("Criminal")
      res = scrape_criminal_data
    end
    return res
  end

  def scrape_criminal_data
    require 'rubygems'
    require 'mechanize'
    require 'nokogiri'
    mechanize = Mechanize.new

    ########## FORM FILL

    page = mechanize.get('http://www.lacourt.org/criminalcasesummary/ui/')
    page = mechanize.submit(page.forms.last)

    page.forms.last.fields[3].value = self.uid

    page = mechanize.submit(page.forms.last)

    ########## SCAN FOR INFO

    noko = Nokogiri::HTML(page.body)

    ########## EXIT IF NO RESULT FOUND
    return false if noko.at('td:contains("Defendant Name")').nil?
    
    defendant_name = noko.at('td:contains("Defendant Name")').next.text.strip
    self.title = defendant_name
    self.save

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
      hearing.case = self
      hearing.save
    end
  end

  def scrape_civil_data
    require 'rubygems'
    require 'mechanize'
    require 'nokogiri'

    mechanize = Mechanize.new

    page = mechanize.get('http://www.lacourt.org/casesummary/ui/index.aspx?casetype=civil')

    test_case_number = self.uid

    case_number_field = page.search("input.textInput")[0]

    form = page.forms.last
    form.field_with(:name=> "CaseNumber").value = test_case_number

    page = mechanize.submit(form)
    noko = Nokogiri::HTML(page.body)

    ########## EXIT IF NO RESULT FOUND
    return false if noko.at('span.boldText:contains("Case Number:")')

    self.title = noko.at('span.boldText:contains("Case Number:")').next.next.next.text.strip

    self.title = noko.at('span.boldText:contains("Case Number:")').next.next.next.text.strip
    self.save

    #get future hearings
    #TODO get multiple (need a sameple case number)
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
        hearing.time = Time.new(sd.year, sd.month, sd.day, st.hour, st.minute)
        hearing.location = parsed_event.message
        hearing.case = self
        hearing.save
      
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
          document.case = self
          document.save

        end
      end

      el = el.next
      if el.attr('class') && el.attr('class')=="dividerGrayLine"
        run = false
      end
    end
  end

end
