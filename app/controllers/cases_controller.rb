class CasesController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!
  before_action :set_case, only: [:show, :edit, :update, :destroy]
  before_action :set_user, :set_firm

  def index
    #@cases = @firm.cases.includes(:medical)
    @new_path = new_case_path
    respond_to do |format|
      format.html
      format.json { render json: CasesDatatable.new(view_context, current_user, false) }
    end
  end

  def show
    @case = Case.find(params[:id])
    restrict_access("cases") if @case.firm_id != @firm.id
  end

  def new
    @case = Case.new

  end

  def edit
    @case = Case.find(params[:id])
    restrict_access("cases") if @case.firm_id != @firm.id
  end
  
  def create
    # inj_type = params[:case][:medical_attributes][:injuries_attributes]["0"][:injury_type]

    # if inj_type != ''
    #   puts "INJURY TYPEE -----> " + inj_type
    #   params[:case][:medical_attributes][:injuries_attributes]["0"][:primary_injury] = true
    # else
    #   params[:case][:medical_attributes].delete(:injuries_attributes)
    # end

    @case = Case.new(case_params)
    @case.user = @user
    @case.firm = @firm

    if @case.case_type == "Personal Injury"
      incident = @case.build_incident
      incident.firm = @firm
      incident.save

      medical = @case.build_medical
      medical.firm = @firm
      medical.save

      insurance = @case.build_insurance
      insurance.firm = @firm
      insurance.save
    end

    resolution = @case.build_resolution
    resolution.firm = @firm
    resolution.save


    # injury = medical.tasks.create
    # injury.firm = @firm
    # injury.save

    if @case.save
      TaskList.where(case_type: @case.case_type, firm_id: @firm.id, task_import: 'automatic').each do |task_list|
        if task_list.case_creator == 'all_firm' || task_list.case_creator == 'owner' && task_list.user_id == @user.id
          task_list.import_to_case!(@case.id, @user.id)
        end
      end
      redirect_to @case, notice: 'Case was successfully created.'
    else
      redirect_to :back, alert: "Please review the problems below: #{@case.errors.full_messages.join('. ')}"
    end
  end

  respond_to :html, :json
  def update
    @case.user = @user
    if @case.update_attributes(case_params)
      tasks = @case.tasks.where(anchor_date: ['trial date', 'close date', 'case open'])
      tasks.each do |task|
        if @case.trial_date.present? && task.due_date.blank? && task.anchor_date == 'trial date'
          task.set_due_date!(@case.trial_date)
        elsif @case.closing_date.present? && task.due_date.blank? && task.anchor_date == 'close date'
          task.set_due_date!(@case.closing_date)
        elsif @case.created_at.present? && task.due_date.blank? && task.anchor_date == 'case open'
          task.set_due_date!(@case.created_at)
        end
      end
      respond_with @case, notice: 'Case was successfully updated.'
    end
  end

  def destroy
    @case.destroy
    redirect_to cases_url, notice: 'Case was successfully deleted.'
  end

  def user_cases
    respond_to do |format|
      format.json { render json: CasesDatatable.new(view_context, current_user, true) }
    end
  end

  private
    def set_case
      @case = Case.find(params[:id])
    end

    def case_params
      params.require(:case).permit(:name, :trial_date, :case_number, :docket_number, :description, :case_type, :subtype,
        :court, :county, :plaintiff, :defendant, :corporation, :status,
        :creation_date, :closing_date, :state, :medical_bills, :topic,
        :medical_attributes => [:total_med_bills, :subrogated_amount, :injuries_within_three_days, :length_of_treatment, :doctor_type, :treatment_type, :created_at, :updated_at, :id, 
        :injuries_attributes => [:injury_type, :region, :code, :created_at, :updated_at, :primary_injury, :id]], 
        :incident_attributes => [:incident_date, :statute_of_limitations, :defendant_liability, :alcohol_involved, :weather_factor, :property_damage, :airbag_deployed, :speed, :police_report, :insurance_provider, :created_at, :updated_at, :id], 
        :insurance_attributes => [:insurance_type, :insurance_provider, :policy_limit, :claim_number, :policy_holder, :created_at, :updated_at, :id], 
        :resolution_attributes => [:id, :updated_at, :created_at, :firm_id, :settlement_demand, :jury_demand, :resolution_amount, :resolution_type], 
        :event_ids => [], :contact_ids => [], :task_ids => [], :document_ids => [])
    end
end
