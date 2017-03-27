class AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment, only: [:index, :show, :edit, :update, :destroy]
  before_action :set_appointments, only: [:index, :new, :edit]

  def index
    if params[:location_id]
      @appointments = Location.find_by(id: params[:location_id]).list_upcoming_appointments
      render "appointments_without_calendar"
    elsif params[:week]
      render "simple_calendar/_weekly_calendar_appointments", locals: {appointments: @appointments}
    elsif params[:list]
      @appointments = current_user.upcoming_appointments
      render "appointments_without_calendar"
    end
  end

  def new
    @appointment = current_user.appointments.build
  end

  def create
    @appointment = Appointment.new(appointment_params.merge(user_id: current_user.id)) #instantiate an appointment associated with user, but unsaved
    if @appointment.save
      redirect_to appointment_path(@appointment)
    else #reset user association on failed appointment, set @appointments to not include failed appointment for partial
      @appointment.user = nil
      @appointments = current_user.appointments.select { |appt| appt.persisted? }
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      flash[:notice] = "Successfully updated appointment!"
      redirect_to appointment_path(@appointment)
    else
      @appointment.user = nil
      @appointments = current_user.appointments.select { |appt| appt.persisted? }
      render :edit
    end
  end

  def destroy
    @appointment.delete
    flash[:notice] = "Successfully deleted appointment!"
    redirect_to appointments_path
  end


  private
  def set_appointments
    @appointments = current_user.appointments.all
  end

  def set_appointment
    @appointment = Appointment.find_by(id: params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:name, :description, :contact_id, :location_id, :start_time, :contact_attributes => [:name, :email, :phone_number], :location_attributes => [:name])
  end

end
