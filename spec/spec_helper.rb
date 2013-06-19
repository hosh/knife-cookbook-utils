require 'chef/knife'

# variable_to_watch.tap(&WATCH)
WATCH = lambda { |o| ap o } unless defined?(WATCH)

# Autoload everything in support
Dir["spec/support/**/*.rb"].map { |f| f.gsub(%r{.rb$}, '') }.each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

