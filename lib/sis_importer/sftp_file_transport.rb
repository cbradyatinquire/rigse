module SisImporter
  class SftpFileTransport < FileTransport
    
    class ConnectionError < Errors::FatalError
    end

    attr_accessor :ssh_session
    attr_accessor :sftp_session

    def defaults
      super.merge({
        :host        => nil,
        :username    => nil,
        :password    => nil,
        :remote_root => nil
      })
    end

    def remote_root
      @opts[:remote_root]
    end

    def remote_path(file)
      File.join(remote_root,file)
    end

    def remote_district_path(district,file)
      return File.join(remote_path(district),file)
    end

    def download(remote, local)
      begin
        sftp = Net::SFTP.start(@opts[:host], @opts[:username] , :password => @opts[:password]) 
        sftp.download!(remote, local)
        logger.info("Downloaded: #{remote} ==>  #{local}")
        sftp.session.close
      rescue NoMethodError => e
        raise ConnectionError.new("Connection Failed: #{@opts[:username]}@#{@opts[:host]}", e)
      rescue RuntimeError => e
        raise TransportError.new("Download Failed: #{@opts[:host]}/#{remote} ==> #{local}", e)
      end
    end
      
    def get_csv_files_for_district(district)
      csv_files.each do |csv_file|
        download(remote_district_path(district,csv_file),local_path(csv_file))
      end
    end

  end
end
