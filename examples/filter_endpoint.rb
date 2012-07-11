require 'nervion'

RED      = "\e[0;31m"
NO_COLOR = "\e[0m"

def print_status(name, status)
  puts "#{RED}#{name.rjust(20)}:#{NO_COLOR} #{status}"
end

# Setup your own keys here
Nervion.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.access_token = ''
  config.access_token_secret = ''
end

EM.run do
  @count = 0

  # This is tracking every tweet that includes the string "madrid" OR any tweet
  # that is geo-located in Madrid.
  Nervion.filter(track: 'madrid', locations: '40.364,-3.760,40.365,-3.609') do |status|
    print_status status[:user][:screen_name], status[:text] if status.has_key? :text
    @count += 1
  end

  # Check the count of streamed statuses every 2 seconds and switch to sample
  # stream after getting 20. Stop after getting 5 statuses through the sample
  # endpoint.
  EM.add_periodic_timer(2) do
    STDERR.puts "Checking the number of tweets: #{@count}"
    if @count > 20
      @count = 0
      STDERR.puts "MORE THAN 20!!!!!! => switching to sample endpoint"
      Nervion.close_stream

      EM.next_tick do
        Nervion.sample do |status|
          @count += 1
          STDERR.puts @count
          Nervion.stop if @count >= 5
        end
      end
    end
  end
end
