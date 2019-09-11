# frozen_string_literal: true

class ApplicationController < ActionController::API
  private

  def render_error(exp)
    Rails.logger.error(exp)
    render json: { error: exp.message }.to_json,
           status: (@error_code || :internal_server_error)
  end
end
