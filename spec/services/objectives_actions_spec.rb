require 'rails_helper'
class DoubleObjectiveOne
  def created_at
    Time.parse '2021-10-21T19:54:45.808Z'
  end
end

class DoubleObjectiveTwo
  def created_at
    Time.parse '2020-10-21T19:54:45.808Z'
  end
end

class DoubleObjectiveThree
  def created_at
    Time.parse '2021-10-21T19:54:45.808Z'
  end
end

ObjectivesActions = ObjetivesActions
describe ObjectivesActions do
  let(:doble_uno){
    double(created_at: Time.parse('2018-10-21T19:54:45.808Z'))
  }

  # it 'Get yearly distributions' do
  #   actual = ObjectivesActions.new
  #   years = actual.get_one_year_distributions(DoubleObjectiveOne.new, [2021])
  #   expect(years).to eq([2021])
  # end
  #
  # it 'Get only disponible years' do
  #   actual = ObjectivesActions.new
  #   years = actual.by_years([DoubleObjectiveOne.new, DoubleObjectiveTwo.new,
  #                            DoubleObjectiveThree.new, doble_uno])
  #
  #   expect(years).to eq([2018, 2020, 2021])
  # end
end
