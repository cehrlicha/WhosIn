class EventsController < ApplicationController
  before_action :set_event, only: [:edit, :update, :destroy, :show]

  def index
    @events = policy_scope(Event).order(created_at: :desc)
  end

  def new
    @event = Event.new
    authorize @event
  end

  def create
    authorize @event
  end

  def edit
    authorize @event

  end

  def update
    authorize @event
    byebug

  end

  def destroy
    authorize @event

  end

  def show
    authorize @event
    @invitation = current_user.invitations.select { |invitation| invitation.event == @event }.first
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end
end
