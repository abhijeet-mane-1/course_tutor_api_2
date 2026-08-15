class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_errors
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing


  private

  def render_validation_errors(exception)
    render json: {
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def render_parameter_missing(exception)
    render json: {
      errors: [exception.message]
    }, status: :bad_request
  end
end
