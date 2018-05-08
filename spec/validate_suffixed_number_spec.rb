# frozen_string_literal: true

require 'validate_suffixed_number'

require 'pry-byebug'

RSpec.describe ValidateSuffixedNumber do
  context "methods" do
    subject { ValidateSuffixedNumber }
    it { is_expected.to respond_to(:parse_numeric_option,
                                   :parse_integer_option,
                                   :parse_number,
                                   :parse_integer)
    }
  end

  describe ".parse_numeric_option" do
    let(:method) { :parse_numeric_option }

    before(:all) do
      @options = {}
      @options2 = {}
    end

    def validated_number(arg)
      @options[:arg] = arg.to_s
      ValidateSuffixedNumber.parse_numeric_option(:arg, @options, "Bad data")
    end

    def validated_number_with_whitespace(arg)
      @options2[:arg] = "  #{arg}  "
      ValidateSuffixedNumber.parse_numeric_option(:arg, @options2, "Bad data")
    end

    context "when given good arguments" do
      [
        ['1.2G'         ,              1_200_000_000   ],
        ['900M',                         900_000_000   ],
        ['650K',                             650_000   ],
        [ '120',                                 120   ],
        ['500m',                         500_000_000   ],
        ['175k',                             175_000   ],
        ['175 K',                            175_000   ],
        ['175 thousand',                     175_000   ],
        ['225g',                     225_000_000_000   ],
        ['225 billion',              225_000_000_000   ],
        ['-1.2G',                     -1_200_000_000   ],
        ['-900M',                       -900_000_000   ],
        ['+650K',                            650_000   ],
        ['-120',                                -120   ],
        ['-500m',                       -500_000_000   ],
        ['+ 175k',                           175_000   ],
        ['- 225g',                  -225_000_000_000   ],
        ['- 763 million',               -763_000_000   ],
        ['- 763 M',                     -763_000_000   ],
        [' 2.3 trillion',          2_300_000_000_000   ],
        ['-4.2 hundred',                        -420   ],
        ['+ 2.9 T',                2_900_000_000_000   ],
        ['+ 4.86 P',           4_860_000_000_000_000   ],
        ['+ 4.86 quadrillion', 4_860_000_000_000_000   ],
        ['+123.4E6',                     123_400_000.0 ], # exponentials
        ['-3.852E-6',                -0.00000385_200   ],
        ['486E',         486_000_000_000_000_000_000   ], # etabyte (non-exponentials)
        ['2.39 Z',     2_390_000_000_000_000_000_000   ], # zetabyte
        ['5.4 Y',  5_400_000_000_000_000_000_000_000   ],
      ].each do |arg, expected_value|

        it "should produce the correct result" do
          @options[:arg] = arg.to_s
          expect(validated_number(arg)).to eq expected_value.to_f
        end

        it "should update the options hash also" do
          @options[:arg] = arg.to_s
          expect { validated_number(arg) }.to change { @options[:arg] }.from(arg).to(expected_value.to_f)
        end

        it "should ignore the whitespace around the number" do
          @options2[:arg] = "  #{arg}  "
          expect(validated_number_with_whitespace(arg)).to eq expected_value.to_f
        end
      end
    end

    context "when given bad or arguments" do
      subject { ValidateSuffixedNumber.parse_numeric_option(:arg, @options, error_msg) }
      let(:error_msg) { "Bad data" }

      context "with no argument" do
        it "should show an error" do
          @options = { arg: nil }
          expect { subject }.to raise_error(ArgumentError, /No value/)
        end
      end

      context "with a bad argment" do
        it "should show an error" do
          @options = { arg: "fuh" }
          expect { subject }.to raise_error(ArgumentError, /#{error_msg}/)
        end
      end

      context "with no explicit error message" do
        let(:error_msg) { nil }
        it "should show the default error message" do
          @options = { arg: "fuh" }
          expect { subject }.to raise_error(ArgumentError, /Bad value for/)
        end
      end
    end
  end

  describe ".parse_number" do
    def validated_number(arg)
      ValidateSuffixedNumber.parse_number(arg.to_s)
    end

    def validated_number_with_whitespace(arg)
      ValidateSuffixedNumber.parse_number(' ' + arg.to_s + ' ')
    end

    def validated_number_with_fraction(arg, fraction)
      numstr = arg.to_s.sub(/(\D)$/, "#{fraction}\1")
      ValidateSuffixedNumber.parse_number(numstr)
    end

    context "when given good data" do
      [
        ['123B', 123_000_000_000],
        ['123G', 123_000_000_000],
        ['456M',     456_000_000],
        ['789K',         789_000],
        ['12.3B', 12_300_000_000],
        ['45.6M',     45_600_000],
        ['78.9',            78.9],
        ['12.3',            12.3]
      ].each do |arg, expected_value|

        it "should produce the correct result" do
          expect(validated_number(arg)).to eq expected_value.to_f
        end

        it "should ignore the whitespace around the number" do
          expect(validated_number_with_whitespace(arg)).to eq expected_value.to_f
        end
      end

      it "should manage plain numbers correctly" do
        expect(ValidateSuffixedNumber.parse_number('1')).to     eq      1
        expect(ValidateSuffixedNumber.parse_number('12')).to    eq     12
        expect(ValidateSuffixedNumber.parse_number('123')).to   eq    123
        expect(ValidateSuffixedNumber.parse_number('1234')).to  eq  1_234
        expect(ValidateSuffixedNumber.parse_number('12345')).to eq 12_345
      end

      it "should handle both lower and upper case suffixes" do
        expect(ValidateSuffixedNumber.parse_number('12.3b')).to eq 12_300_000_000
        expect(ValidateSuffixedNumber.parse_number('1.23g')).to eq  1_230_000_000
        expect(ValidateSuffixedNumber.parse_number('45.6m')).to eq     45_600_000
        expect(ValidateSuffixedNumber.parse_number('7.89k')).to eq          7_890
        expect(ValidateSuffixedNumber.parse_number('78.9K')).to eq         78_900
        expect(ValidateSuffixedNumber.parse_number('12.3M')).to eq     12_300_000
      end

      it "should handle suffixes with a leading whitespace" do
        expect(ValidateSuffixedNumber.parse_number('12.3 b')).to eq 12_300_000_000
        expect(ValidateSuffixedNumber.parse_number('1.23 g')).to eq  1_230_000_000
        expect(ValidateSuffixedNumber.parse_number('45.6 m')).to eq     45_600_000
        expect(ValidateSuffixedNumber.parse_number('7.89 k')).to eq          7_890
        expect(ValidateSuffixedNumber.parse_number('78.9 K')).to eq         78_900
        expect(ValidateSuffixedNumber.parse_number('12.3 M')).to eq     12_300_000
      end
    end

    context "when given no data" do
      it "should return a nil" do
        expect(ValidateSuffixedNumber.parse_number(nil)).to eq nil
      end
    end

    context "when given bad data" do
      it "should return a nil" do
        expect(ValidateSuffixedNumber.parse_number('feh')).to eq nil
      end
    end
  end

  describe ".parse_integer" do
    let(:method) { :parse_integer }

    context "when given good arguments" do
      it "should truncate floats to integers" do
        expect(ValidateSuffixedNumber.parse_integer('78.9')).to eq 78
        expect(ValidateSuffixedNumber.parse_integer('12.3')).to eq 12
      end

      it "should properly parse integers" do
        expect(ValidateSuffixedNumber.parse_integer('123')).to   eq    123
        expect(ValidateSuffixedNumber.parse_integer('1234')).to  eq  1_234
        expect(ValidateSuffixedNumber.parse_integer('12345')).to eq 12_345
      end

      context "when given no data" do
        it "should return a nil" do
          expect(ValidateSuffixedNumber.parse_integer('')).to eq nil
        end
      end

      context "when given bad data" do
        it "should return a nil" do
          expect(ValidateSuffixedNumber.parse_integer('gronk!')).to eq nil
        end
      end
    end
  end
end
