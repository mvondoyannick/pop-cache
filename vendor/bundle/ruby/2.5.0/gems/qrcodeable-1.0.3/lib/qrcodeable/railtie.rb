module Qrcodeable
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveRecord::Base.send(:extend, Qrcodeable::Hook)
    end
  end
end