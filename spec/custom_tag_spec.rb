# frozen_string_literal: true

RSpec.describe CustomTag do
  it "has a version number" do
    expect(CustomTag::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
