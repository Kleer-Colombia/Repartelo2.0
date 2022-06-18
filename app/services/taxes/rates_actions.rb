class RatesActions

  def add_trm trm
    date = Date.parse(trm[:date][0,10])
    old_trm = RepresentativeMarketRate.find_by(date: date)
    if old_trm
      return old_trm.update(rate: trm[:rate])
    else
      new_trm = RepresentativeMarketRate.new(rate: trm[:rate], date: trm[:date], currency: trm[:currency])
      new_trm.save!
      return new_trm
    end
  end
end
