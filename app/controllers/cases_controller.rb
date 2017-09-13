class CasesController < ApplicationController
  before_action :set_case, only: [:show, :edit, :update, :destroy]

  # GET /cases
  # GET /cases.json
  def index
    @cases = Case.all

    @info = ""

    require 'rubygems'
    require 'mechanize'
    require 'nokogiri'

    mechanize = Mechanize.new

    @cases.each do |kase|
      @info += "<br>"
      @info +=  '<b>CASE: ' + kase.uid + '</b><br>'
      @info += "<br>"
      
      page = mechanize.get('http://www.lacourt.org/casesummary/ui/index.aspx?casetype=civil')

      test_case_number = kase.uid

      case_number_field = page.search("input.textInput")[0]

      form = page.forms.last
      form.field_with(:name=> "CaseNumber").value = test_case_number

      page = mechanize.submit(form)

      noko = Nokogiri::HTML(page.body)

      el = noko.at('span.contentSubHeading:contains("Future Hearings")')

      future_hearings = []

      @info += "<br>"
      @info +=  '<b>FUTURE HEARINGS</b><br>'
      @info += "<br>"

      run = true
      while run
        el = el.next

        if el.name == 'b'
          date = el.text.strip
          text = el.next.text

          @info += date + text
        end

        if el.attr('class') && el.attr('class')=="dividerGrayLine"
          run = false
        end
      end
      @info += "<br>"
      @info += "<br>"

      @info += '<b>DOCUMENTS FILED</b>'
      @info += "<br>"
      el = noko.at('span.contentSubHeading:contains("Documents Filed")')
      run = true
      while run
        if el.name == "p"
          matches = el.text.match /([0-1][0-9]\/[0-3][0-9]\/[0-9]{4})\s(.*)(Filed\sby\s.*)/
          unless matches.nil?
            date = matches[1]
            title = matches[2]
            filed_by = matches[3]
            @info += date + title + filed_by
            @info += "<br>"
          end
        end
        el = el.next
        if el.attr('class') && el.attr('class')=="dividerGrayLine"
          run = false
        end
      end

      @info += "<br>"
      @info += "<br>"

    end

    
  end

  # GET /cases/1
  # GET /cases/1.json
  def show
  end

  # GET /cases/new
  def new
    @case = Case.new
  end

  # GET /cases/1/edit
  def edit
  end

  # POST /cases
  # POST /cases.json
  def create
    @case = Case.new(case_params)

    respond_to do |format|
      if @case.save
        format.html { redirect_to @case, notice: 'Case was successfully created.' }
        format.json { render :show, status: :created, location: @case }
      else
        format.html { render :new }
        format.json { render json: @case.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cases/1
  # PATCH/PUT /cases/1.json
  def update
    respond_to do |format|
      if @case.update(case_params)
        format.html { redirect_to @case, notice: 'Case was successfully updated.' }
        format.json { render :show, status: :ok, location: @case }
      else
        format.html { render :edit }
        format.json { render json: @case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cases/1
  # DELETE /cases/1.json
  def destroy
    @case.destroy
    respond_to do |format|
      format.html { redirect_to cases_url, notice: 'Case was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_case
      @case = Case.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def case_params
      params.require(:case).permit(:uid)
    end
end
