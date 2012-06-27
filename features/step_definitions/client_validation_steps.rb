AUTHENTICATION_README_URL = 'https://github.com/jacegu/nervion#authentication'

Given /^I haven't configured Nervion$/ do
  Nervion::Configuration.instance_variable_set '@configured', nil
end

When /^I try to start streaming$/ do
  begin
    Nervion.sample { |status| puts status }
  rescue Exception => error
    puts error
    @error = error
  end
end

Then /^I get an error pointing me to the readme file$/ do
  @error.message.should match /#{AUTHENTICATION_README_URL}/
end
