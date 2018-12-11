require 'rails_helper'

describe Accounter do

  before(:each) do
    @accounter = Accounter.new(Kleerer.new(name: 'KleerCo', option: Option.new(name: 'Home', value: 0), id: 100000000))
    @accounter.option_kleer_co = 0.18
    @accounter.option_kleerer = 0.82

    allow_any_instance_of(Balance).to receive(:save!).and_return(true)
    @balance = Balance.new(project: 'project',
                          client: 'client',
                          description: 'description')

    allow(Balance).to receive(:find).with(@balance.id).and_return(@balance)

    @socio = Kleerer.new(name: 'socio',option: Option.new(name: 'Socio', value: 5), id: 1000)
    @socio2 = Kleerer.new(name: 'socio2',option: Option.new(name: 'Socio', value: 5), id: 2000)
    @other = Kleerer.new(name: 'other', option: Option.new(name: 'Otro', value: 10), id: 1001)
    @full = Kleerer.new(name: 'full',option: Option.new(name: 'Full', value: 15), id: 1002)
    @partial = Kleerer.new(name: 'partial',option: Option.new(name: 'Parcial', value: 25), id: 1003)
  end

  context "calculate distribution" do
    it "for 'socio' " do

      @balance.incomes.push Income.new(description: 'descrip', amount: 1000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @socio))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 221
      expect(distributions[1].amount).to eq 779
    end

    it "for 'socio' with other numbers" do

      @balance.incomes.push Income.new(description: 'descrip', amount: 6969.66)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @socio))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 1540.29
      expect(distributions[1].amount).to eq 5429.37
    end

    it "for 'other' " do

      @balance.incomes.push Income.new(description: 'descrip', amount: 10000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @other))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 2620
      expect(distributions[1].amount).to eq 7380
    end

    it "for 'other' with other numbers" do

      @balance.incomes.push Income.new(description: 'descrip', amount: 12605)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @other))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 3302.51
      expect(distributions[1].amount).to eq 9302.49
    end

    it "for 'full'" do

      @balance.incomes.push Income.new(description: 'descrip', amount: 5560000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @full))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 1684680
      expect(distributions[1].amount).to eq 3875320
    end


    it "for 'parcial'" do

      @balance.incomes.push Income.new(description: 'descrip', amount: 5560000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @partial))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 2140600
      expect(distributions[1].amount).to eq 3419400
    end
  end

  context "distribute for multiples kleerers" do
    it "with 2 socios at 50 - 50 " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @socio2))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 221000
      expect(distributions[1].amount).to eq 389500
      expect(distributions[2].amount).to eq 389500
    end

    it "with socio and full at 25-75 " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 75, kleerer: @full))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 282500
      expect(distributions[1].amount).to eq 194750
      expect(distributions[2].amount).to eq 522750
    end

    it "with socio and full at 50 - 50 " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @full))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 262000
      expect(distributions[1].amount).to eq 389500
      expect(distributions[2].amount).to eq 348500
    end

    it "with all at 25 each one " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @full))
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @partial))
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @other))

      distributions = @accounter.distribute(@balance.id)

      expect(distributions[0].amount).to eq 292750
      expect(distributions[1].amount).to eq 194750
      expect(distributions[2].amount).to eq 174250
      expect(distributions[3].amount).to eq 153750
      expect(distributions[4].amount).to eq 184500

    end

    it "with not percentages" do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      expect {@accounter.distribute(@balance.id)}.to raise_error('How to distribute?')
    end
  end

  context "calculate total incomes" do
    it "without incomes" do
      total = @accounter.calculate_total_incomes(@balance)
      expect(total).to eq 0
    end

    it "with one income" do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000)
      total = @accounter.calculate_total_incomes(@balance)
      expect(total).to eq 1000
    end

    it "with many incomes" do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000)
      @balance.incomes.push Income.new(description: 'descrip', amount: 10000)
      @balance.incomes.push Income.new(description: 'descrip', amount: 2200)
      @balance.incomes.push Income.new(description: 'descrip', amount: 55.66)

      total = @accounter.calculate_total_incomes(@balance)

      expect(total).to eq 13255.66
    end
  end

  context "calculate total expenses" do
    it "without expenses" do
      total = @accounter.calculate_total_expenses(@balance)
      expect(total).to eq 0
    end

    it "with one expense" do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 5647.56)
      total = @accounter.calculate_total_expenses(@balance)
      expect(total).to eq 5647.56
    end

    it "with many expenses" do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 1000)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 10000)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 2200)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 55.66)

      total = @accounter.calculate_total_expenses(@balance)
      expect(total).to eq 13255.66
    end
  end

  context 'calculate profit' do
    it 'with positive profit' do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 2200)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 800)
      @balance.incomes.push Income.new(description: 'descrip', amount: 12200)
      @balance.incomes.push Income.new(description: 'descrip', amount: 800)
      total = @accounter.calculate_profit(@balance)
      expect(total).to eq 10000
    end

    it 'with negative profit' do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 12200)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 800)
      @balance.incomes.push Income.new(description: 'descrip', amount: 2200)
      @balance.incomes.push Income.new(description: 'descrip', amount: 800)

      expect { @accounter.calculate_profit(@balance)}.
          to raise_error('Nothing to distribute!')
    end
  end

end