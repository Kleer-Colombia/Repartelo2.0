require 'rails_helper'

describe DistributeBalanceService do

  before(:each) do

    allow_any_instance_of(Balance).to receive(:save!).and_return(true)
    @balance = Balance.new(project: 'project',
                           client: 'client',
                           description: 'description')
    @balance.id = 10

    allow(Balance).to receive(:find).with(@balance.id).and_return(@balance)

    @socio = Kleerer.new(name: 'socio',option: Option.new(name: 'Socio', value: 5), id: 1000)
    @socio2 = Kleerer.new(name: 'socio2',option: Option.new(name: 'Socio', value: 5), id: 2000)
    @other = Kleerer.new(name: 'other', option: Option.new(name: 'Otro', value: 10), id: 1001)
    @full = Kleerer.new(name: 'full',option: Option.new(name: 'Full', value: 15), id: 1002)
    @partial = Kleerer.new(name: 'partial',option: Option.new(name: 'Parcial', value: 25), id: 1003)
    @kleerCo = Kleerer.new(name: 'KleerCo', option: Option.new(name: 'Home', value: 0), id: 100000000)

    allow(Kleerer).to receive(:find_by).with(name: @kleerCo.name).and_return(@kleerCo)

    allow(Kleerer).to receive(:find).with(@kleerCo.id).and_return(@kleerCo)
    allow(Kleerer).to receive(:find).with(@socio.id).and_return(@socio)
    allow(Kleerer).to receive(:find).with(@socio2.id).and_return(@socio2)
    allow(Kleerer).to receive(:find).with(@full.id).and_return(@full)
    allow(Kleerer).to receive(:find).with(@other.id).and_return(@other)
    allow(Kleerer).to receive(:find).with(@partial.id).and_return(@partial)

  end

  context "calculate distribution" do
    it "must be have taxes " do

      @balance.incomes.push Income.new(description: 'descrip', amount: 1000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @socio))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq false
      expect(db.errors[:messages][0]).to eq "error on distribution balance: the balance must have taxes"
    end

    it "for 'socio'" do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @socio))
      @balance.taxes.push(Tax.new(name: 'ica', amount: 11, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 25, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 250.64, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 71.34, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount]).to eq 103.44
      expect(db.result[1][:amount]).to eq 609.92
    end

    it "for 'socio' with other numbers" do

      @balance.incomes.push Income.new(description: 'descrip', amount: 6969.66)
      @balance.expenses.push Expense.new(description: 'descrip', amount: 1000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @socio))
      @balance.taxes.push(Tax.new(name: 'ica', amount: 76.67, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 174.24, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 1486.88, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 423.19, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount]).to eq 613.62
      expect(db.result[1][:amount]).to eq 3618.25
    end

    it "for 'other' " do

      @balance.incomes.push Income.new(description: 'descrip', amount: 10000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @other))
      @balance.taxes.push(Tax.new(name: 'ica', amount: 110, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 250, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 2506.40, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 713.36, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount]).to eq 1355.38
      expect(db.result[1][:amount]).to eq 5778.22
    end

    it "for 'full'" do

      @balance.incomes.push Income.new(description: 'descrip', amount: 5560000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @full))
      @balance.taxes.push(Tax.new(name: 'ica', amount: 61160.00, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 139000.00, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 1393558.40, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 396628.16, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount].to_f).to eq 932076.18
      expect(db.result[1][:amount].to_f).to eq 3034205.42
    end

    it "for 'parcial'" do

      @balance.incomes.push Income.new(description: 'descrip', amount: 5560000)
      @balance.percentages.push(Percentage.new(value: 100, kleerer: @partial))

      @balance.taxes.push(Tax.new(name: 'ica', amount: 61160.00, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 139000.00, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 1393558.40, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 396628.16, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount].to_f).to eq 1289041.52
      expect(db.result[1][:amount].to_f).to eq 2677240.08
    end
  end

  context "distribute for multiples kleerers" do
    it "with 2 socios at 50 - 50 " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @socio2))

      @balance.taxes.push(Tax.new(name: 'ica', amount: 11000.00, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 25000.00, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 250640.00, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 71336.00, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount].to_f).to eq 103437.20
      expect(db.result[1][:amount].to_f).to eq 304961.40
      expect(db.result[2][:amount].to_f).to eq 304961.40
    end

    it "with socio and full at 25-75 " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 75, kleerer: @full))

      @balance.taxes.push(Tax.new(name: 'ica', amount: 11000.00, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 25000.00, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 250640.00, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 71336.00, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount].to_f).to eq 151589.00
      expect(db.result[1][:amount].to_f).to eq 152480.70
      expect(db.result[2][:amount].to_f).to eq 409290.30
    end

    it "with socio and full at 50 - 50 " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 50, kleerer: @full))

      @balance.taxes.push(Tax.new(name: 'ica', amount: 11000.00, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 25000.00, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 250640.00, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 71336.00, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount].to_f).to eq 135538.40
      expect(db.result[1][:amount].to_f).to eq 304961.40
      expect(db.result[2][:amount].to_f).to eq 272860.20
    end

    it "with all at 25 each one " do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @socio))
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @full))
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @partial))
      @balance.percentages.push(Percentage.new(value: 25, kleerer: @other))

      @balance.taxes.push(Tax.new(name: 'ica', amount: 11000.00, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 25000.00, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 250640.00, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 71336.00, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq true
      expect(db.result[0][:amount].to_f).to eq 159614.30
      expect(db.result[1][:amount].to_f).to eq 152480.70
      expect(db.result[2][:amount].to_f).to eq 136430.10
      expect(db.result[3][:amount].to_f).to eq 120379.50
      expect(db.result[4][:amount].to_f).to eq 144455.40

    end

    it "with not percentages" do
      @balance.incomes.push Income.new(description: 'descrip', amount: 1000000)

      @balance.taxes.push(Tax.new(name: 'ica', amount: 11000.00, percentage: 1.1))
      @balance.taxes.push(Tax.new(name: 'chanchito', amount: 25000.00, percentage: 2.5))
      @balance.taxes.push(Tax.new(name: 'retefuente', amount: 250640.00, percentage: 26))
      @balance.taxes.push(Tax.new(name: 'kleerCo', amount: 71336.00, percentage: 10))

      db = DistributeBalanceService.new(balance_id: @balance.id)
      db.call

      expect(db.success?).to eq false
      expect(db.errors[:messages][0]).to eq "error on distribution balance: How to distribute?"

    end
  end

end