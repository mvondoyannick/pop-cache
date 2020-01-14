# toutes les historiques et les journaux de la plateforme
module CoreHistory

  class Journal

    # Generate History
    # @param [Object] argv
    def self.generate(argv)
      @customer = argv[:customer]
      @code = argv[:code]
      @flag = argv[:flag]
      @context = argv[:context]
      @amount = argv[:amount]

      generate = History.new(customer_id: @customer, code: @code, flag: @flag, context: @context, amount: @amount)

      if generate.save
        return true
      else
        return false
      end
    end
  end

end