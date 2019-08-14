module Qrcodeable
  module Core

    class QrcodeableError < StandardError
      def self.invalid_identifier(i)
        "Please add column #{i} by running migration"
      end

      def self.no_directory(d = nil)
        dir = d.nil? ? "qrcodes/downloads" : d
        "Please create a directory #{dir} in #{Rails.root.to_s}"
      end
    end

    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def qrcodeable(args = {})
        mattr_accessor :identifier, :print_path, :expire_mode, :expire_column
        self.identifier = args[:identifier] || :key
        self.print_path = args[:print_path] || "qrcodes/downloads"
        self.expire_mode = args[:expire_mode] || false
        self.expire_column = args[:expire_column] || :expired_date
      end
    end

    def generate_qrcode
      begin
        return ::RQRCode::QRCode.new(instance_value_of(self.identifier).to_s, level: :h)
      rescue RuntimeError => e
        raise QrcodeableError.invalid_identifier(self.identifier)
      end
    end

    def print_qrcode
      begin
        qrcode = generate_qrcode
        png = qrcode.as_png(
                  resize_gte_to: false,
                  resize_exactly_to: false,
                  fill: 'white',
                  color: 'black',
                  size: 512,
                  border_modules: 0,
                  module_px_size: 1,
                  file: nil # path to write
                  )
        path = qrcode_path
        File.open(path, 'wb') do |file|
          file.write(png.to_s)
        end
        return path
      rescue Errno::ENOENT => e
        raise QrcodeableError.no_directory(self.print_path)
      rescue RuntimeError => e
        raise QrcodeableError.invalid_identifier(self.identifier)
      end
    end

    def qrcode_path
      begin
        ::Rails.root.to_s+"/"+self.print_path+"/"+instance_value_of(self.identifier).to_s+".png"
      rescue RuntimeError => e
        raise QrcodeableError.invalid_identifier(self.identifier)
      end
    end

    def qrcode_expired?
      if can_expire?
        if instance_value_of(self.expire_column)
          (Time.now > instance_value_of(self.expire_column))
        else
          false
        end 
      else
        false
      end
    end

    def can_expire?
      self.expire_mode
    end

    private
    def instance_value_of(column)
      self.send(column)
    end

  end
end