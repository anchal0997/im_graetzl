class MeetingsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  def show
    @graetzl = Graetzl.find(params[:graetzl_id])
    @meeting = Meeting.find(params[:id])
  end

  def new
    @graetzl = Graetzl.find(params[:graetzl_id])
    @meeting = @graetzl.meetings.build
    @meeting.build_address
  end

  # def edit
  # end

  def create
    @graetzl = Graetzl.find(params[:graetzl_id])
    @meeting = @graetzl.meetings.create(meeting_params)
    @meeting.address = Address.new_from_json_string(params[:feature] || '')
    @meeting.address.description = meeting_params[:address_attributes][:description]
    current_user.go_to(@meeting, GoingTo::ROLES[:initator])
    @meeting.complete_datetimes
    
    respond_to do |format|
      if @meeting.save
        format.html { redirect_to graetzl_meeting_path(@graetzl, @meeting), notice: 'Neues Treffen wurde erstellt.' }
      else
        format.html { render :new }
      end
    end
  end

  # def update
  #   respond_to do |format|
  #     if @meeting.update(meeting_params)
  #       format.html { redirect_to @meeting, notice: 'Meeting was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @meeting }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @meeting.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # def destroy
  #   @meeting.destroy
  #   respond_to do |format|
  #     format.html { redirect_to meetings_url, notice: 'Meeting was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def meeting_params
      params.require(:meeting).permit(:name,
        :description,
        :feature,
        :starts_at_date, :starts_at_time,
        :ends_at_time,
        :cover_photo,
        category_ids: [],
        address_attributes: [:description])
    end
end
