# There's no need for us to use Unicorn in development as it may be a source
# of issues for some people.

if defined? Unicorn
  # Using the WEB_CONCURRENCY environment variable if set or defaulting to 3
  #
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || ENV["ORIENTATION_DYNO_COUNT"])
  timeout 15
  preload_app true

  before_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
      Process.kill 'QUIT', Process.pid
    end

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
  end

  after_fork do |server, worker|
    Signal.trap 'TERM' do
      puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
    end

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
  end
end
