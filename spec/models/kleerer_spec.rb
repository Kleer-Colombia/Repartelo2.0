require 'rails_helper'

RSpec.describe Kleerer, type: :model do
  let(:option) { Option.create!(name: 'home', value: 0) }

  before { Kleerer.create!(name: 'KleerCo', option: option) }

  it 'no permite repetir un nombre' do
    expect(Kleerer.new(name: 'KleerCo', option: option)).not_to be_valid
  end

  it 'no permite repetirlo con otras mayúsculas' do
    expect(Kleerer.new(name: 'kleerco', option: option)).not_to be_valid
  end

  it 'permite un nombre distinto' do
    expect(Kleerer.new(name: 'Juli', option: option)).to be_valid
  end
end
