class Case < ApplicationRecord
  has_many :documents, dependent: :destroy
  has_many :hearings, dependent: :destroy

  after_create :scrape_data

  def scrape_data
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

    el = noko.at('span.contentSubHeading:contains("Future Hearings")')

    #get future hearings
    run = true
    while run
      el = el.next

      if el.name == 'b'
        text = el.text + el.next.text
        parsed_time = text.match /(\d{2})\/(\d{2})\/(\d{4})\sat\s(\d{2}:\d{2}\s\w\w)/
        title = text

        hearing = Hearing.new
        hearing.time = "#{parsed_time[3]}-#{parsed_time[1]}-#{parsed_time[2]} #{parsed_time[4]}"
        hearing.title = title
        hearing.case = self
        hearing.save
      
      end

      if el.attr('class') && el.attr('class')=="dividerGrayLine"
        run = false
      end
    end

    el = noko.at('span.contentSubHeading:contains("Documents Filed")')
    run = true
    while run
      if el.name == "p"
        matches = el.text.match /([0-1][0-9]\/[0-3][0-9]\/[0-9]{4})\s(.*)(Filed\sby\s.*)/
        unless matches.nil?

          date = matches[1]
          title = matches[2]
          filed_by = matches[3]

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
