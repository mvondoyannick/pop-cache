class AddTypeRechargeToSolutionRecharge < ActiveRecord::Migration[5.2]
  def change
    add_reference :solution_recharges, :type_recharge, foreign_key: true
  end
end
