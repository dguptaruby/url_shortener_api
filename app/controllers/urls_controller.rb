# frozen_string_literal: true

class UrlsController < ApplicationController
  before_action :find_url, only: :show

  def create
    url = Url.new(url_params)
    url.sanitize
    if url.new_url?
      if url.save
        short_url = shortened(url)
        FetchTitleJob.perform_later(url)
        render json: { short_url: short_url }
      else
        render json: url.errors, status: :unprocessable_entity
      end
    else
      update_access_count(url)
      render json: { short_url: short_url }
    end
  rescue StandardError => e
    render_error(e)
  end

  def top
    urls_data = []
    urls = Url.order(access_count: :desc).limit(100)
    urls.each do |url|
      urls_data << { title: url.title, short_url: shortened(url) }
    end
    render json: urls_data
  rescue StandardError => e
    render_error(e)
  end

  def shortened(url)
    host = request.host_with_port
    host + '/' + url.short_url
  end

  def show
    if @url.nil?
      render json: 'No url found'
    else
      update_access_count(@url)
      render json: @url.sanitized_url
    end
  rescue StandardError => e
    render_error(e)
  end

  private

  def find_url
    @url = Url.find_by(short_url: params[:short_url])
  end

  def url_params
    params.require(:url).permit(:original_url)
  end

  def update_access_count(url)
    new_access_count = url.access_count + 1
    url.update(access_count: new_access_count)
  end
end
