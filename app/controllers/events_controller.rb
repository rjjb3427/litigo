class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @user = current_user
    @events = @user.owned_events

    if params[:order] && ["asc", "desc"].include?(params[:sort_mode])
      order = params[:order].split(",").map {|o| "#{o} #{params[:sort_mode]}" }.join(", ")
      @events = @events.order(order)
    end
    if params[:search].present? && params[:utf8] == "✓"
      logger.info"#{params[:search]}"
      @events = @events.search(params[:search])

    end
    @events = @events.paginate(:per_page => 10, :page => params[:page])

  end

  # GET /events/1
  # GET /events/1.json
  def show
    @user = current_user
  end

  # GET /events/new
  def new
    @user = current_user
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    @user = current_user
  end

  # POST /events
  # POST /events.json
  def create
    @user = current_user
    @event = Event.new(event_params)

    @event.owner = @user

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @user = current_user
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @user = current_user
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:subject, :location, :date, :time, :all_day, :reminder, :notes, :owner_id, :user_ids => [], :case_ids => [], :attorney_ids => [])
    end
end