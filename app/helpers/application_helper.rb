module ApplicationHelper
  # @param [String] amount
  def un_hash(amount)
    if amount.is_a?(String)
      begin
        new_amount = JWT.decode amount, Rails.application.secrets.secret_key_base, false
        new_amount[0].to_f.round(2)
      rescue JWT::DecodeError
        return "Une erreur est survenue, chaine invalide"
      end
    end
  end
end
