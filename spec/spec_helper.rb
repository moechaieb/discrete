$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'math/discrete'
