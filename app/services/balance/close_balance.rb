class CloseBalance
  prepend Service

  attr_accessor :balance, :alegra_client, :saldos
  def initialize(balance_id)
    @balance = Balance.find(balance_id)
    @alegra_client = AlegraClientFactory.build
    #TODO move this for a service.
    @saldos =  SaldosActions.new
  end

  def call
    if can_close_the_balance?
      distributions = @balance.distributions
      distributions.each do |distribution|
        @saldos.add_saldo(distribution: distribution, balance: balance)
      end
      balance.editable = false
      balance.save!
    else
      errors.add(:messages, " Las facturas asociadas al balance no se encuentran cerradas en Alegra.
 El balance solo se puede enviar a saldos cuando las facturas esten cerradas.")
      errors.add(:error_code, :not_acceptable)
    end
  end

  private

  def can_close_the_balance?
    invoice_ids = @balance.get_invoice_ids
    can_close = true
    invoice_ids.each do |invoice_id|
      can_close = @alegra_client.is_invoice_closed? invoice_id
    end
    can_close
  end


end