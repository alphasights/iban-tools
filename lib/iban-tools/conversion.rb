module IBANTools
  class Conversion

    def self.local2iban(country_code, data)
      config = load_config country_code

      bban = config.map do |key, value|
        value[1] % data[key.to_sym].gsub(/^0+/, '')
      end.join('').gsub(/\s/, '0')

      check_digits = "%02d" % checksum(country_code, bban)

      IBAN.new "#{country_code}#{check_digits}#{bban}"
    end


    def self.iban2local(country_code, bban)
      config = load_config country_code

      if config
        local = {}
        config.map do |key, value|
          local[key.to_sym] = bban.scan(/^#{value[0]}/).first.sub(/^0+/, '')
          bban.sub!(/^#{value[0]}/, '')
        end
        local
      end
    end

    def self.iban2bic(country_code, bban)
      require 'banking_data'
      local = iban2local(country_code, bban)
      country = country_code.downcase.to_sym
      if local.respond_to?(:[]) && local[:blz]
        bic = BankingData::Bank.where(:locale => country, :blz => local[:blz]).
          only(:bic).
          flatten.
          first
        bic
      end
    rescue LoadError
      require 'logger'
      logger = Logger.new(STDOUT)
      logger.warn 'You have tried to convert an IBAN to BIC without ' +
                  'installing the `banking_data` gem'
      nil
    end

    private

    def self.default_config
      @@default_config ||= YAML.
        load(File.read(File.dirname(__FILE__) + '/conversion_rules.yml'))
    end

    def self.load_config(country_code)
      default_config[country_code]
    end

    def self.checksum(country_code, bban)
      97 - (IBAN.new("#{country_code}00#{bban}").numerify.to_i % 97) + 1
    end
  end
end
