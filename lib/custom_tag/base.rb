module CustomTag
  class Base
    @@tags = {}

    def self.register(tag_name, klass)
      @@tags[tag_name.to_s] = klass
      @@tags[tag_name.to_s.gsub(/([A-Z])/) { |m| "_#{m.downcase}" }] = klass
      @@tags[tag_name.to_s.gsub(/([A-Z])/) { |m| "-#{m.downcase}" }] = klass
      @@tags[tag_name.to_s.tr("_", "-").downcase] = klass
      @@tags[tag_name.to_s.gsub(/_([a-z])/) { |m| m[1].upcase }] = klass
      @@tags[tag_name.to_s.tr("-", "_").downcase] = klass
      @@tags[tag_name.to_s.gsub(/-([a-z])/) { |m| m[1].upcase }] = klass
      @@tags[tag_name.to_s.delete("-").downcase] = klass
      @@tags[tag_name.to_s.delete("_").downcase] = klass
      @@tags[tag_name.to_s.downcase] = klass
    end

    def self.tags
      @@tags
    end

    def self.replace(tag_name, attrs, content)
      ret = if @@tags[tag_name]
        @@tags[tag_name].build(tag_name, attrs, content)
      else
        build(tag_name, attrs, content)
      end

      doc = Nokogiri::XML.fragment(ret)
      doc.search("*").each do |element|
        if CustomTag::Base.tags[element.name]
          element.replace(CustomTag::Base.replace(element.name, element.attributes, element.content))
        end
      end
      doc.to_html.strip
    end

    def self.build(tag_name, attrs, content)
      "<#{tag_name} #{attrs.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")}>#{content}</#{tag_name}>"
    end
  end
end
