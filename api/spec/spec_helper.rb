# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'simplecov'
require 'rails_helper'
require 'shoulda/matchers'

SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  # config.profile_examples = 10
  config.order = :random
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model
end
