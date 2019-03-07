require 'rails_helper'

describe Balance do

  before(:each) do
    @balance = Balance.new(project: 'project',
                           client: 'client',
                           description: 'description')

  end

  context "calculate total incomes" do
    it "without incomes" do
      total = @balance.total_incomes
      expect(total).to eq 0
    end

    it "with one income" do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000)
      total = @balance.total_incomes
      expect(total).to eq 1000
    end

    it "with many incomes" do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000)
      @balance.incomes.push Income.new(description: 'descrip', amount: 10000)
      @balance.incomes.push Income.new(description: 'descrip', amount: 2200)
      @balance.incomes.push Income.new(description: 'descrip', amount: 55.66)

      total = @balance.total_incomes

      expect(total).to eq 13255.66
    end
  end

  context "calculate total expenses" do
    it "without expenses" do
      total = @balance.total_expenses
      expect(total).to eq 0
    end

    it "with one expense" do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 5647.56)
      total = @balance.total_expenses
      expect(total).to eq 5647.56
    end

    it "with many expenses" do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 1000)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 10000)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 2200)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 55.66)

      total = @balance.total_expenses
      expect(total).to eq 13255.66
    end
  end

  context 'calculate profit' do
    it 'with positive profit' do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 2200)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 800)
      @balance.incomes.push Income.new(description: 'descrip', amount: 12200)
      @balance.incomes.push Income.new(description: 'descrip', amount: 800)
      total = @balance.calculate_profit
      expect(total).to eq 10000
    end

    it 'with negative profit' do
      @balance.expenses.push Expense.new(description: 'descrip', amount: 12200)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 800)
      @balance.incomes.push Income.new(description: 'descrip', amount: 2200)
      @balance.incomes.push Income.new(description: 'descrip', amount: 800)

      expect { @balance.calculate_profit}.
          to raise_error('Nothing to distribute!')
    end
  end
end



describe 'Test service: Calculator' do
    describe 'Test method: plus' do
        it '5 + 5 = 10'do
            calculator = Calculator.new
            response = calculator.plus 5, 5
            expect(response).to.equal 10
         end
        it '4 + 3 = 7' do
            calculator = Calculator.new
            response = calculator.plus 4, 3
            expect(response).to.equal 7
        end
    end
end