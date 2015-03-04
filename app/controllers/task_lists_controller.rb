class TaskListsController < ApplicationController
  before_action :set_task_list, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_action :set_user, :set_firm
  respond_to :html, :xml, :json

  def index
    @task_lists = @firm.task_lists
    respond_with(@task_lists)
  end

  def show
    respond_with(@task_list)
  end

  def new
    @task_list = TaskList.new
    respond_with(@task_list)
  end

  def edit
    unless @task_list.user == @user || @task_list.amend_permission == 'all_firm' || ['admins', 'admins_attorneys'].include?(@task_list.amend_permission) && @user.is_admin? || @task_list.amend_permission == 'admins_attorneys' && @user.is_attorney?
      redirect_to task_lists_path, alert: "You can't edit this task list."
    end
  end

  def create
    @task_list = TaskList.new(task_list_params)
    @task_list.user = @user
    @task_list.firm = @firm
    respond_to do |format|
      if @task_list.save
        format.html { redirect_to task_lists_path, notice: "Task List was successfully created." }
      else
        format.html { render action: "new" }
        format.json { render json: @task_list.errors.full_messages.join('. '), :status => :unprocessable_entity }
      end
    end
  end

  def update
    if @task_list.user == @user || @task_list.amend_permission == 'all_firm' || ['admins', 'admins_attorneys'].include?(@task_list.amend_permission) && @user.is_admin? || @task_list.amend_permission == 'admins_attorneys' && @user.is_attorney?
      respond_to do |format|
        if @task_list.update_attributes(task_list_params)
          format.html  { redirect_to task_lists_path, :notice => 'Task List was successfully updated.' }
        else
          format.html  { redirect_to edit_task_list_path(@task_list), :alert => "#{@task_list.errors.full_messages.join('. ')}" }
          format.json  { render :json => @task_list, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to task_lists_path, alert: "You can't edit this task list."
    end
  end

  def destroy
    if @task_list.user == @user || @task_list.amend_permission == 'all_firm' || ['admins', 'admins_attorneys'].include?(@task_list.amend_permission) && @user.is_admin? || @task_list.amend_permission == 'admins_attorneys' && @user.is_attorney?
      @task_list.destroy
    end
    respond_with(@task_list)
  end

  def import_to_case
    if import_to_case_params[:task_lists_ids].blank?
      message = 'Please select task lists to import'
    else
      # TODO create tasks from task_drafts
      message = 'Task lists were imported'
    end

    respond_to do |format|
      format.json { render :json => {message: message}, status: :ok }
    end
  end

  private
    def set_task_list
      @task_list = TaskList.find(params[:id])
    end

    def task_list_params
      params.require(:task_list).permit(:name, :view_permission, :amend_permission, :task_import,
                                        task_drafts_attributes: [:id, :name, :parent_id, :description, :due_term, :conjunction, :anchor_date, :_destroy,
                                        children_attributes: [:id, :name, :parent_id, :task_list_id, :description, :due_term, :conjunction, :anchor_date, :_destroy]
                                        ])
    end

    def import_to_case_params
      params.require(:task_list).permit(:case_id, :task_lists_ids => [])
    end
end
