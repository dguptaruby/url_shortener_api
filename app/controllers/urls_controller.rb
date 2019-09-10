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
      new_access_count = url.access_count + 1
      url.update(access_count: new_access_count)
      render json: { short_url: short_url }
    end
  end

  def top
    urls_data = []
    urls = Url.order(access_count: :desc).limit(100)
    urls.each do |url|
      urls_data << { title: url.title, short_url: shortened(url) }
    end
    render json: urls_data
  end

  def shortened(url)
    host = request.host_with_port
    host + '/' + url.short_url
  end

  def show
    render json: @url.sanitized_url
  end

  private

  def find_url
    @url = Url.find_by(short_url: params[:short_url])
  end

  def url_params
    params.require(:@url).permit(:original_url)
  end
end
