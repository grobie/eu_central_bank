class EuCentralBank < Money::Bank::EuCentral
  def initialize(*args)
    Money.deprecate "EuCentralBank is deprecated and will be removed in v0.2.0. " +
                    "Use Money::Bank::EuCentral instead."
    super
  end
end

class Money
  module Bank
    class EuCentral

      def exchange(cents, from_currency, to_currency)
        Money.deprecate '`exchange` will be removed in money v3.2.0 and eu_central_bank v0.2.0, use #exchange_with instead'
        exchange_with(Money.new(cents, from_currency), to_currency)
      end

    end
  end
end