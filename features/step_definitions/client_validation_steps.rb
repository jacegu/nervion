AUTHENTICATION_README_URL = 'https://github.com/jacegu/nervion'

def capture_errors_in
  begin
    yield
  rescue Exception => error
    @error = error
  end
end

Given /^I haven't configured Nervion$/ do
  Nervion::Configuration.instance_variable_set '@configured', nil
end

When /^I try to start streaming$/ do
  capture_errors_in { Nervion.sample { |status| puts status } }
end

When /^I try to start streaming the (.*?) endpoint$/ do |endpoint_name|
  params = { stall_warnings: true }
  capture_errors_in { Nervion.send(endpoint_name.to_sym, params) }
end

Then /^I get an error pointing me to the readme file$/ do
  @error.message.should match /#{AUTHENTICATION_README_URL}/
end
