class EventsController < ApplicationController
  before_action :set_event, only: [:update, :destroy, :show]

  def index
    @events = policy_scope(Event).order(created_at: :desc)
  end

  def new
  end

  def create
    @event = Event.create(start_date: DateTime.new(24/12/2018), end_date: DateTime.new(25/12/2018), address:"Eiffel Tower", title:"My amazing event")
    @invitation = Invitation.new
    @invitation.event = @event
    @invitation.user = current_user
    @invitation.role = "manager"
    @invitation.save
    authorize @event
    redirect_to edit_event_path(@event)

  end

  def edit
    @menu_item = MenuItem.new
    @event = Event.find(params[:id])
    authorize @event
    @menu_items = @event.menu_items
    @fb_friends = []

    fb_friends = current_user.facebook.get_connection("me","friends").map do |friend|
    friend.name
    end
  end



  def update
    @event = Event.find(params[:id])
    authorize @event
    if !event_params["menu_items_attributes"].nil? && event_params["menu_items_attributes"]["0"]["id"] == nil
      if menu_create(@event, event_params)
        redirect_to edit_event_path(@event)
      else
        render 'edit'
      end
    elsif !event_params["menu_items_attributes"].nil? && !event_params["menu_items_attributes"]["0"]["id"].nil?
      if menu_update(@event, event_params)
        redirect_to edit_event_path(@event)
      else
        render 'edit'
      end
    else
      if @event.update(event_params)
        redirect_to edit_event_path(@event)
      else
        render 'edit'
      end
    end
  end

  def menu_create(event, parameters)
    @menu_item = MenuItem.new(event: event)
    @menu_item.name = parameters["menu_items_attributes"]["0"]["name"]
    @menu_item.quantity = parameters["menu_items_attributes"]["0"]["quantity"]
    @menu_item.category = parameters["menu_items_attributes"]["0"]["category"]
    @menu_item.save
  end

  def menu_update(event, parameters)
    @menu_item = MenuItem.where(event: event)
    @menu_item.name = parameters["menu_items_attributes"]["0"]["name"]
    @menu_item.quantity = parameters["menu_items_attributes"]["0"]["quantity"]
    @menu_item.category = parameters["menu_items_attributes"]["0"]["category"]
    @menu_item.save
  end

  def destroy
    authorize @event

  end

  def show
    authorize @event
    @invitation = current_user.invitations.select { |invitation| invitation.event == @event }.first
  end

  private

  def event_params
    params.require(:event).permit(:start_date, :end_date, :address, :description, :title, :photo, menu_items_attributes: [:id, :name, :category, :quantity])
  end

  def set_event
    @event = Event.find(params[:id])
  end
end
