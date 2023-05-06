require 'rails_helper'

RSpec.describe Kleerer, type: :model do
  let(:percentage_gain) { Option.new(name: 'home', value: 0) }

  before { Kleerer.create!(name: 'KleerCo', option: percentage_gain) }

  it '::colombia' do
    expect(Kleerer.colombia.name).to eq('KleerCo')
  end

  describe '#name' do
    it 'is not valid when name taken' do
      actual = Kleerer.new(name: 'KleerCo', option: percentage_gain)
      expect(actual).to_not be_valid
    end
  end
end
