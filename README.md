# ValidateSuffixedNumber

The `validate_suffixed_number` gem provides a simple interface for parsing
strings of numbers possibly suffixed by magnitude abbreviations. For example,
'10K', '1.2M', '9.3B', etc.

It deals correctly with the special case of 'E', which can mean either 'exa'
(quintillion), or scientific notation when followed immediately by other
digits: '10.2E3'

There are two pairs of interfaces: two for parsing and converting a string into either 
an integer or float, and two for parsing a specific keyed value from a hash, which makes
it easier to use with hashes produced by Thor and other similar command-line libraries.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'validate_suffixed_number'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install validate_suffixed_number

## Usage

    ValidateSuffixedNumber

    ValidateSuffixedNumber.parse_number(string_arg)

    ValidateSuffixedNumber.parse_integer(string_arg)

    ValidateSuffixedNumber.parse_numeric_option(key, options, error_msg = nil)

    ValidateSuffixedNumber.parse_integer_option(key, options, error_msg = nil)

## Examples

The simple interfaces:

    ValidateSuffixedNumber.parse_number('1.2K')  == 1200.0
    ValidateSuffixedNumber.parse_integer('1.2K') == 1200
    ValidateSuffixedNumber.parse_number('9.3B')  == 9_300_000_000.0
    ValidateSuffixedNumber.parse_integer('4.2M') == 4_200_000

The keyed hash interfaces:

    ValidateSuffixedNumber.parse_integer_option(:batch_size, options, "Bad --batch_size option")

    ValidateSuffixedNumber.parse_numeric_option(:population, options, "Bad --population value")

The above examples are based on the `thor` gem, where the `options` value is a hash 
with symbolic keys based on the configured command-line options, with values also 
obtained from the parsed command-line.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Author

Alan K. Stebbens `<aks@stebbens.org>`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aks/validate_suffixed_number. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ValidateSuffixedNumber project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/aks/validate_suffixed_number/blob/master/CODE_OF_CONDUCT.md).
