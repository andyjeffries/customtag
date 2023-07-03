# frozen_string_literal: true

require "nokogiri"
require_relative "custom_tag/version"
require_relative "custom_tag/base"

module CustomTag
  class Error < StandardError; end

  def self.parse_and_replace(content)
    doc = Nokogiri::HTML.parse(content)
    doc.search("*").each do |element|
      if CustomTag::Base.tags[element.name]
        element.replace(CustomTag::Base.replace(element.name, element.attributes, element.children.to_html))
      end
    end
    doc.to_html
  end
end
