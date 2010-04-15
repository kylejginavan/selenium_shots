module SeleniumShots::Command
	class Server < Base

    GEM_ROOT        = File.expand_path(File.join(File.dirname(__FILE__), '/../../../../'))
    SELENIUM_SERVER = File.join(GEM_ROOT, 'vendor', 'selenium-server-1.0.2-SNAPSHOT-standalone.jar')

    def pid_file
      '/tmp/selenium_shots.pid'
    end

    def start
      if File.exists?(pid_file)
        puts "the selenium shots server is running...."
      else
        pipe = IO.popen("java -jar #{SELENIUM_SERVER}")
        File.open(pid_file, 'w') {|f| f.write(pipe.pid) }
      end
    end

    def stop
      if File.exists?(pid_file)
        process_id = File.open(pid_file,'r').readline
        Process.kill 9, process_id.to_i
        FileUtils.rm(pid_file)
      end
    end

    def help
      puts "selenium_shots_local_server {start|stop}"
    end

	end
end

