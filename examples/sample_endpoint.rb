require 'nervion'

CYAN     = "\e[0;36m"
NO_COLOR = "\e[0m"

def print_non_status(text)
  puts "#{CYAN}#{text}#{NO_COLOR}"
end

# Setup your own keys here
Nervion.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.access_token = ''
  config.access_token_secret = ''
end

@deleted_count = 0
# Calculate the percentage of delete statuses streamed through the sample endpoint.
Nervion.sample(stall_warnings: true) do |status|
  @count += 1
  if status.has_key? :delete
    print_non_status status
    @deleted_count += 1
  end

  if @count >= 1000
    Nervion.stop
    percentage = (@deleted_count * 100.0) / @count
    puts "#@deleted_count out of #@count were deleted tweets (#{percentage.round(2)}%)"
  end
end
