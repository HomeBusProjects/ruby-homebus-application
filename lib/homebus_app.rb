require 'dotenv'

# based on Jake Gordon's excellent article, "Daemonizing Ruby Processes"
# https://codeincomplete.com/posts/ruby-daemons/

class HomeBusApp
  attr_reader :options, :quit, :homebus_server, :homebus_port, :mqtt_server, :mqtt_port, :mqtt_username, :mqtt_password
  
  def initialize(options)
    @options = options
    @quit = false
    
    # daemonization will change CWD so expand relative paths now
    options[:logfile] = File.expand_path(logfile) if logfile?
    options[:pidfile] = File.expand_path(pidfile) if pidfile?
  end

  def run!
    check_pid
    daemonize if daemonize?
    write_pid
    trap_signals

    if logfile?
      redirect_output
    elsif daemonize?
      suppress_output
    end

    setup!

    load_provisioning!
    while !provision!
      sleep 60
    end

    while !quit
      work!
    end

  end

  def load_provisioning!
    Dotenv.load(provisioning_file)

    @homebus_server = options[:homebus_server] || ENV['HOMEBUS_SERVER']
    @homebus_port = options[:homebus_port] || ENV['HOMEBUS_PORT']

    @mqtt_server = ENV['MQTT_SERVER']
    @mqtt_port = ENV['MQTT_PORT']
    @mqtt_username = ENV['MQTT_USERNAME']
    @mqtt_password = ENV['MQTT_PASSWORD']
  end

  def save_provisioning!(info)
    File.open(provisioning_file, 'w') do |f|
      f.puts "MQTT_SERVER=#{info[:host]}"
      f.puts "MQTT_PORT=#{info[:port]}"
      f.puts "MQTT_USERNAME=#{info[:username]}"
      f.puts "MQTT_PASSWORD=#{info[:password]}"
      f.puts "UUID=#{info[:uuid]}"
    end
  end
    

  def provision!
    if mqtt_server && mqtt_port && mqtt_username && mqtt_password
      return true
    end

    unless homebus_server && homebus_port
      abort "No HomeBus provisioning server info"
    end

    mqtt = HomeBus.provision serial_number: serial_number,
                           manufacturer: manufacturer,
                           model: model,
                           friendly_name: friendly_name,
                           friendly_location: friendly_location,
                           pin: pin,
                           devices: devices,
                           provisioner_name: @homebus_server,
                           provisioner_port: @homebus_port

  unless mqtt
    abort 'MQTT provisioning failed'
  end

  save_provisioning! mqtt
  load_provisioning!

  @mqtt = MQTT::Client.connect mqtt

  true
  end

  def daemonize?
    options[:daemonize]
  end

  def provisioning_file
    options[:provisioning_file] || '.env.provisioning'
  end

  def logfile
    options[:logfile]
  end

  def pidfile
    options[:pidfile]
  end

  def logfile?
    !logfile.nil?
  end

  def pidfile?
    !pidfile.nil?
  end
  
  def trap_signals
    trap(:QUIT) do   # graceful shutdown of run! loop
      @quit = true
    end
  end

  def suppress_output
    $stderr.reopen('/dev/null', 'a')
    $stdout.reopen($stderr)
  end

  def redirect_output
    FileUtils.mkdir_p(File.dirname(logfile), :mode => 0755)
    FileUtils.touch logfile
    File.chmod(0644, logfile)
    $stderr.reopen(logfile, 'a')
    $stdout.reopen($stderr)
    $stdout.sync = $stderr.sync = true
  end

  def daemonize
    exit if fork
    Process.setsid
    exit if fork
    Dir.chdir "/"
  end

  def check_pid
    if pidfile?
      case pid_status(pidfile)
      when :running, :not_owned
        puts "A server is already running. Check #{pidfile}"
        exit(1)
      when :dead
        File.delete(pidfile)
      end
    end
  end

  def pid_status(pidfile)
    return :exited unless File.exists?(pidfile)
    pid = ::File.read(pidfile).to_i
    return :dead if pid == 0
    Process.kill(0, pid)      # check process status
    :running
  rescue Errno::ESRCH
    :dead
  rescue Errno::EPERM
    :not_owned
  end

  def write_pid
    if pidfile?
      begin
        File.open(pidfile, ::File::CREAT | ::File::EXCL | ::File::WRONLY){|f| f.write("#{Process.pid}") }
        at_exit { File.delete(pidfile) if File.exists?(pidfile) }
      rescue Errno::EEXIST
        check_pid
        retry
      end
    end
  end
end
