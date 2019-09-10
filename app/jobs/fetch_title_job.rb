# frozen_string_literal: true

class FetchTitleJob < ApplicationJob
  queue_as :default

  def perform(url)
    # Do something later
    title = Nokogiri::HTML::Document.parse(HTTParty.get(url.sanitized_url).body).title
    Url.update(title: title)
  end
end
