$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'discrete'
require 'simplecov'

SimpleCov.start

require 'codecov'

SimpleCov.formatter = SimpleCov::Formatter::Codecov
