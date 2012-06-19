$: << File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'nervion'
require 'eventmachine'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end
