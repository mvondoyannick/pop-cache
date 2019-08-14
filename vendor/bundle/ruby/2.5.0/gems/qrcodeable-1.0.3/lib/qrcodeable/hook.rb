module Qrcodeable
  module Hook
    def qrcodeable(*args)
      options = args.extract_options!
      
      include Qrcodeable::Core
      qrcodeable(options)
    end
  end
end