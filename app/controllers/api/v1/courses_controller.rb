class Api::V1::CoursesController < ApplicationController
  def index
    @courses = Course.includes(:tutors)

    render :index, formats: :json, status: :ok
  end

  def create
    @course = Course.create!(course_params)

    render :show, formats: :json, status: :created
  end

  private

  def course_params
    params.require(:course).permit(
      :title,
      :description,
      tutors_attributes: %i[name email]
    )
  end
end