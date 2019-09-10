# frozen_string_literal: true

class Url < ApplicationRecord
  UNIQUE_ID_LENGTH = 6
  validates :original_url, presence: true
  # validates_format_of :original_url, with: /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  before_create :generate_short_url
  before_create :sanitize

  def generate_short_url
    url = [*('a'..'z'), *('0'..'9')].sample(UNIQUE_ID_LENGTH).join
    old_url = Url.where(short_url: url).last
    if old_url.present?
      generate_short_url
    else
      self.short_url = url
    end
  end

  def find_duplicate
    Url.find_by_sanitized_url(sanitized_url)
  end

  def new_url?
    find_duplicate.nil?
  end

  def sanitize
    original_url.strip!
    self.sanitized_url = original_url.downcase.gsub(%r{(https?://)|(www\.)}, '')
    sanitized_url.slice!(-1) if sanitized_url[-1] == '/'
    self.sanitized_url = "http://#{sanitized_url}"
  end
end
