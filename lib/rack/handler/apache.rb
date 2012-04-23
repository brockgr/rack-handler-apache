require "phusion_passenger"

module Rack
  module Handler
    class Apache

      def self.valid_options
        {
          "Port=PORT" => "Port to listen on (default: 8080)",
          #TODO#"Host=HOST" => "Hostname to listen on (default: localhost)",
        }
      end

      def self.run(app, options={})

        unless ::File.exists? ::PhusionPassenger::APACHE2_MODULE
          puts "Passenger apache module missing, did you run passenger-install-apache2-module?"
          exit
        end

        @root      = ::Dir.pwd
        @port      = options[:Port] || 8080
        @pid_file  = "#{@root}/tmp/rack-helper-apache.pid"
        @conf_file = "#{@root}/tmp/httpd.conf"
        @passenger = `bundle exec passenger-install-apache2-module --snippet`

        puts "Warning: Please use SSLCertificateFile, not SSLCertificate" if
          options[:SSLCertificate] && !options[:SSLCertificateFile]

        puts "Warning: Please use SSLPrivateKeyFile, not SSLPrivateKey" if
          options[:SSLPrivateKey] && !options[:SSLPrivateKeyFile]

        config = <<-EOD.gsub(/^ {10}/, '')
          #{@passenger}
          User #{Etc.getlogin}
          Listen #{@port}
          PidFile #{@pid_file}
          ErrorLog #{@root}/log/rack-helper-apache_error.log
          LockFile #{@root}/tmp/rack-helper-apache.lock
          ServerName localhost
          <VirtualHost *:#{@port}>
            ServerName localhost
            #{options[:SSLEnable] ? "SSLEngine on" : ""}
            DocumentRoot #{@root}/public
            <Directory #{@root}/public>
              AllowOverride all
              Options -MultiViews
            </Directory>
          </VirtualHost>
        EOD

        if options[:SSLEnable]
          config = <<-EOD.gsub(/^ {12}/, '')+config
            LoadModule ssl_module libexec/apache2/mod_ssl.so
            SSLCertificateFile #{options[:SSLCertificateFile]}
            SSLCertificateKeyFile #{options[:SSLPrivateKeyFile]}
            SSLSessionCache none
          EOD
        end



        kill_httpd()
        ::File.open(@conf_file, 'w') { |f| f.write(config) }
        system(apache_bin,'-f',@conf_file)

        print "Waiting for apache to start..."
        10.times { break if is_running?;  sleep 0.5; print "."; STDOUT.flush }

        if is_running?
          puts "...started [pid:#{get_pid}]"
          sleep 0.5 while is_running?
          puts "Apache terminated."
        else
          puts "...never started!"
          exit
        end

      end


      def self.shutdown()
        kill_httpd()
      end

    private


      # Locate apache - since sbin is often not in the path,
      # we check there too - with a strong OS-X bias
      def self.apache_bin()
        [ 'apache2', 'httpd' ].each do |b|
          ENV['PATH'].split(':')+[
            '/opt/local/sbin',
            '/sw/sbin',
            '/usr/local/sbin',
            '/usr/sbin'
          ].each do |d|
            d_b = ::File.join(d,b)
            return d_b if ::File.executable? d_b
          end
        end
        return false;
      end


      def self.get_pid
        if ::File.exists? @pid_file
          ::File.read(@pid_file).to_i
        end
      end

      def self.is_running?
        if pid=get_pid
          begin
            ::Process.kill 0, pid
            return true
          rescue Errno::ESRCH => e
          end
        end
        return false
      end

      def self.kill_httpd()
        if pid = get_pid
          puts "Killing apache [pid:#{pid}]..."
          ::Process.kill "TERM", pid
          ::File.unlink @pid_file
          sleep 1
        end
      end

    end
  end
end