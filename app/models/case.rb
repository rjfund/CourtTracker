class Case < ApplicationRecord
  belongs_to :user
  belongs_to :case_type
  has_many :documents, dependent: :destroy
  has_many :hearings, dependent: :destroy
  attr_accessor :name


  before_create :check_data
  after_create :scrape_data

  def check_data
    if self.case_type == CaseType.find_by_title("Civil")
      check_civil_data
    elsif self.case_type == CaseType.find_by_title("Criminal")
      check_criminal_data
    end
  end

  def check_civil_data
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
    throw :abort if noko.at('span.boldText:contains("Case Number:")').nil?
  end

  def check_criminal_data
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
    throw :abort if noko.at('td:contains("Defendant Name")').nil?
  end

  def scrape_data
    if self.case_type == CaseType.find_by_title("Civil")
      scrape_civil_data
    elsif self.case_type == CaseType.find_by_title("Criminal")
      scrape_criminal_data
    end
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

    self.title = noko.at('b:contains("Case Number:")').parent.parent.children.last.text.strip

    self.hearings << scrape_hearings(noko)
    self.documents << scrape_docs(noko)

    self.save
  end

  def scrape_hearings(noko)
    el = noko.at('[name="SCH"]').parent
    hearings = []
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
        hearing.title = el.next.next.next.text
        hearing.case = self
        hearings << hearing
      end

      if el.attr('class') && el.attr('class')=="contentHeading"
        run = false
      end
    end
    hearings
  end

  def scrape_docs(noko)
    docs = []
    el = noko.at('[name="DOC"]').parent

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
          docs << document
        end
      end

      el = el.next

      if el.attr('class') && el.attr('class')=="contentHeading"
        run = false
      end
    end

    docs
  end

  def update_data
    if self.case_type == CaseType.find_by_title("Civil")
      update_civil_data
    elsif self.case_type == CaseType.find_by_title("Criminal")
      update_criminal_data
    end
  end

  def update_civil_data
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

    #UPDATE HEARINGS
    current_hearings = scrape_hearings(noko)

    new_hearings = []
    current_hearings.each do |current_hearing|

      match = self.hearings.select do |hearing|
        hearing.time==current_hearing.time && hearing.title==current_hearing.title
      end

      if match.empty?
        current_hearing.needs_email = true
        new_hearings << current_hearing
      end
    end

    #UPDATE DOCS
    current_docs = scrape_docs(noko)

    new_documents = []
    current_docs.each do |current_doc|

      match = self.documents.select do |doc|
        doc.title==current_doc.title && doc.date==current_doc.date
      end

      if match.empty?
        current_doc.needs_email = true
        new_documents << current_doc
      end
    end

    self.documents << new_documents
    self.hearings << new_hearings

  end

  def update_criminal_data
  end

end
