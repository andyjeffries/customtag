# frozen_string_literal: true

class Simple < CustomTag::Base
  register :simple, self

  def self.build(_, attrs, content)
    attrs["class"] = "text-red-500 #{attrs["class"]}".strip
    super("div", attrs, content)
  end
end

class ComplexName < CustomTag::Base
  register :complex_underscore, self
  register :complexCapital, self
  register "complex-dash", self

  def self.build(_, attrs, content)
    super("div", attrs, content)
  end
end

RSpec.describe CustomTag do
  it "has a version number" do
    expect(CustomTag::VERSION).not_to be nil
  end

  it "registers simple subclasses" do
    expect(CustomTag::Base.tags.keys).to include("simple")
  end

  it "registers automatically converted subclasses" do
    expect(CustomTag::Base.tags.keys).to include("complex_underscore")
    expect(CustomTag::Base.tags.keys).to include("complex-underscore")
    expect(CustomTag::Base.tags.keys).to include("complexUnderscore")
    expect(CustomTag::Base.tags.keys).to include("complexunderscore")
    expect(CustomTag::Base.tags.keys).to include("complex-capital")
    expect(CustomTag::Base.tags.keys).to include("complex_capital")
    expect(CustomTag::Base.tags.keys).to include("complexCapital")
    expect(CustomTag::Base.tags.keys).to include("complexcapital")
    expect(CustomTag::Base.tags.keys).to include("complex-dash")
    expect(CustomTag::Base.tags.keys).to include("complex_dash")
    expect(CustomTag::Base.tags.keys).to include("complexDash")
    expect(CustomTag::Base.tags.keys).to include("complexdash")
  end

  it "converts a simple tag" do
    doc = Nokogiri::HTML(<<~EOT)
      <!DOCTYPE html>
      <html>
        <body>
          <simple src="apple.png">Title here</simple>
        </body>
      </html>
    EOT
    element = doc.search('simple')[0]
    expect(CustomTag::Base.replace("simple", element.attributes, element.content)).to eq("<div src=\"apple.png\" class=\"text-red-500\">Title here</div>")
  end

  it "converts a complex tag in each format" do
    doc = Nokogiri::HTML(<<~EOT)
      <!DOCTYPE html>
      <html>
        <body>
          <complex_underscore src="apple.png">Title here</complex_underscore>
          <complex-underscore src="banana.png">Title here</complex-underscore>
          <complexUnderscore src="pear.png">Title here</complexUnderscore>
        </body>
      </html>
    EOT
    element = doc.search('complex_underscore')[0]
    expect(CustomTag::Base.replace("complex_underscore", element.attributes, element.content)).to eq("<div src=\"apple.png\">Title here</div>")
    element = doc.search('complex-underscore')[0]
    expect(CustomTag::Base.replace("complex-underscore", element.attributes, element.content)).to eq("<div src=\"banana.png\">Title here</div>")
    element = doc.search('complexunderscore')[0]
    expect(CustomTag::Base.replace("complexunderscore", element.attributes, element.content)).to eq("<div src=\"pear.png\">Title here</div>")
  end

  it "converts a nested tag set" do
    doc = <<~EOT
      <!DOCTYPE html>
      <html>
        <body>
          <complex_underscore src="apple.png">
            Before
            <simple src="banana.png">During</simple>
            After
          </complex_underscore>
        </body>
      </html>
    EOT

    output = CustomTag.parse_and_replace(doc)

    success = <<~EOT
      <!DOCTYPE html>
      <html>
        <body>
          <div src="apple.png">
            Before
            <div src="banana.png" class="text-red-500">During</div>
            After
          </div>
        </body>
      </html>
    EOT

    expect(output).to eq(success)
  end

  it "operates on a whole page very quickly" do
    doc = File.read("spec/fixtures/normal.html")
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    output = CustomTag.parse_and_replace(doc)
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    milliseconds = (ending - starting) * 1000
    expect(milliseconds).to be < 25
  end
end
