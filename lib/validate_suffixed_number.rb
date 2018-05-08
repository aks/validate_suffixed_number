# frozen_string_literal: true

# Class to parse and validate suffixed numbers.
class ValidateSuffixedNumber
  # methods for validating strings as optionally suffixed numbers (floats or integers)
  SI_MULTIPLIERS = {
    'hundred':     10**2,
    'thousand':    10**3,  'K': 10**3,              # kilo
    'million':     10**6,  'M': 10**6,              # mega
    'billion':     10**9,  'B': 10**9,  'G': 10**9, # giga
    'trillion':    10**12, 'T': 10**12,             # tera
    'quadrillion': 10**15, 'P': 10**15,             # peta
    'quintillion': 10**18, 'E': 10**18,             # exa
    'sextillion':  10**21, 'Z': 10**21,             # zeta
    'septillion':  10**24, 'Y': 10**24,             # yotta
  }.freeze
  SI_ABBREVIATIONS = SI_MULTIPLIERS.keys.select { |k| k.length == 1 }
  SI_MAGNIFIERS    = SI_MULTIPLIERS.keys.select { |k| k.length > 1 }

  ABBREVIATIONS_RE = /^((?:[+-]\s*)?\d[\d_]*(?:\.\d*)?)\s*([#{SI_ABBREVIATIONS}])$/i
  MAGNIFIERS_RE    = /^((?:[+-]\s*)?\d[\d_]*(?:\.\d*)?)\s*(#{SI_MAGNIFIERS.join('|')})$/i
  SCIENTIFIC_RE    = /^(?:[+-]\s*)?\d[\d_]*(?:\.\d*)?[Ee][+-]?\d+$/
  FLOAT_RE         = /^(?:[+-]\s*)?\d[\d_]*(?:\.\d*)?$/
  INTEGER_RE       = /^(?:[+-]\s*)?\d[\d_]*$/

  class << self
    def parse_numeric_option(key, options, error_msg = nil)
      parse_value_option(key, options, :parse_number, error_msg)
    end

    def parse_integer_option(key, options, error_msg = nil)
      parse_value_option(key, options, :parse_integer, error_msg)
    end

    def parse_integer(string_arg)
      parse_number(string_arg)&.to_i
    end

    def parse_number(string_arg)
      str = string_arg&.strip
      if SCIENTIFIC_RE.match?(str) # scientific notation?
        str.to_f
      elsif (mdata = MAGNIFIERS_RE.match(str))
        # eg: 1.2 billion, 12 trillion, 1500 thousand, 15000
        suffix = mdata[2].downcase.to_sym
        mdata[1].sub(' ', '').to_f * SI_MULTIPLIERS[suffix]
      elsif (mdata = ABBREVIATIONS_RE.match(str))
        # eg: 1.2G, 12T, 1500K, 15000
        suffix = mdata[2].upcase.to_sym
        mdata[1].gsub(' ', '').to_f * SI_MULTIPLIERS[suffix]
      elsif FLOAT_RE.match?(str)
        str.sub(' ', '').to_f
      elsif INTEGER_RE.match?(str)
        str.sub(' ', '').to_i
      end
    end

    private

    def parse_value_option(key, options, validator, error_msg = nil)
      options ||= {}
      arg = options[key]&.strip
      error("No value given for --#{key}") if arg.nil?
      (options[key] = send(validator, arg)) ||
        error_message(error_msg || "Bad value for --#{key}: '%s'", arg)
    end

    def error_message(msg, arg)
      if msg.include?('%s')
        error sprintf(msg, arg)
      else
        error "#{msg}: '#{arg}'"
      end
    end

    def error(msg)
      raise ArgumentError, msg
    end
  end
end
