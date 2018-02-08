class CasesController < ApplicationController

  before_action :set_case, only: [:show, :edit, :update, :destroy]

  # GET /cases
  # GET /cases.json
  def index
    @cases = current_user.cases.sort_by(&:title)
    @documents = current_user.documents
    @hearings = current_user.hearings

    @case = Case.new
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
    @case.user = current_user

    respond_to do |format|
      if @case.save
        format.html { redirect_to cases_path, notice: 'Case was successfully created.' }
        format.json { render :show, status: :created, location: @case }
      else
        format.html { redirect_to cases_path, flash: {error: "Case not found."} }
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
    def set_case
      @case = Case.find(params[:id])
    end

    def case_params
      params.require(:case).permit(:uid, :case_type_id )
    end
end
