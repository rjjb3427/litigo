class ClientIntakesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_client_intake, only: [:show, :edit, :update, :destroy, :accept_case]
  before_action :set_user, :set_firm

  # GET /client_intakes
  # GET /client_intakes.json
  def index
    # @leads = @firm.leads
    # @my_leads = @leads.where(attorney_id: current_user.id)
    @lead = Lead.new
    respond_to do |format|
      format.html
      format.json { render json: LeadsDatatable.new(view_context, current_user, false) }
    end
  end

  # GET /client_intakes/1
  # GET /client_intakes/1.json
  def show
  end

  # GET /client_intakes/new
  def new
    @lead = Lead.new
  end

  # GET /client_intakes/1/edit
  def edit
  end

  # POST /client_intakes
  # POST /client_intakes.json
  def create
    @lead = Lead.new(client_intake_params)
    @lead.firm = @firm
    @lead.screener_id = current_user.id
    respond_to do |format|
      if @lead.save
        format.html { redirect_to leads_path, notice: 'Client intake was successfully created.' }
        format.json { render :show, status: :created, location: @lead }
      else
        format.html { render :new }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /client_intakes/1
  # PATCH/PUT /client_intakes/1.json
  def update
    respond_to do |format|
      if @lead.update(client_intake_params)
        format.html { redirect_to @lead, notice: 'Client intake was successfully updated.' }
        format.json { render :show, status: :ok, location: @lead }
      else
        format.html { render :edit }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client_intakes/1
  # DELETE /client_intakes/1.json
  def destroy
    @lead.destroy
    respond_to do |format|
      format.html { redirect_to leads_url, notice: 'Client intake was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def user_leads
    respond_to do |format|
      format.json { render json: LeadsDatatable.new(view_context, current_user, true) }
    end
  end

  def accept_case
    return redirect_to lead_path(@lead), alert: "Case already creaded from that lead" if @lead.case.present?
    case_attributes = @lead.generate_case_attrs(@user)
    @case = Case.new(case_attributes)
    respond_to do |format|
      if @case.save
        @lead.update(case_id: @case.id)
        format.html { redirect_to case_path(@case), notice: 'Case was successfully created.' }
        format.json { render :show, status: :created, location: @case }
      else
        format.html { redirect_to request.referer, alert: "#{@case.errors.full_messages.join('. ')}" }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client_intake
      @lead = Lead.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_intake_params
      params.require(:lead).permit(:first_name, :last_name, :attorney_id, :note, :phone, :marketing_channel, :referred_by, :screener_id, :case_type, :sub_type, :estimated_value, :lead_policy_limit, :primary_injury, :primary_region, :incident_date, :case_summary, :status, :appointment_date, :attorney_already, :attorney_name, :dob, :email, :address, :city, :zip_code, :state)
    end
end