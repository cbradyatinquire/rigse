require File.expand_path('../../../spec_helper', __FILE__)

describe SisImporter::SftpFileTransport do
  before(:each) do

    @district    = "plymouth"
    @output_dir  = "fake_dir"
    @csv_files   = %w[a b c]
    @usename     = "knowuh"
    @host        = "localhost"
    @password    = "secret"
    @remote_root = "root"

    @opts = {
      :district    => @district,
      :output_dir  => @output_dir,
      :csv_files   => @csv_files,
      :host        => @host,
      :username    => @usernane,
      :password    => @password,
      :remote_root => @remote_root
    }
    @sft_trasport = SisImporter::SftpFileTransport.new(SisImporter::Configuration.new(@opts))
  end

    describe  "remote_path(file)" do
      it "should be the remote_root + filename" do
        @filename = 'foo'
        @sft_trasport.remote_path(@filename).should eql File.join(@remote_root,@filename)
      end
    end

    describe  "remote_distrcit_path" do
      it "should be the remote_root + district + filename" do
        @filename = 'foo'
        @sft_trasport.remote_district_file(@filename).should eql File.join(@remote_root,@district,@filename)
      end
    end

    describe  "download(remote, local)" do
      describe "with invalid connection params" do
        it "should throw a connection error" do
          # this is the error that gets raised when connection parameteres are bad.
          Net::SFTP.should_receive(:start).and_raise(NoMethodError.new("undefined method `shutdown!' for nil:NilClass"))
          lambda {@sft_trasport.download('x','y')}.should raise_error(SisImporter::Errors::ConnectionError)
        end
      end

      describe "with missing remote files" do
        it "should throw a transfer error" do
          @sftp = mock("sftp")
          @sftp.stub_chain(:session, :close).and_return true
          Net::SFTP.stub!(:start => @sftp)
          @sftp.should_receive(:download!).twice.and_raise(RuntimeError.new("open x: no such file (2)"))
          lambda {@sft_trasport.download('x','y')}.should_not raise_error(SisImporter::Errors::ConnectionError)
          lambda {@sft_trasport.download('x','y')}.should raise_error(SisImporter::Errors::TransportError)
        end
      end

      describe "with no errors" do
        it "shouldn't raise any exceptions" do
          @sftp = mock("sftp")
          @sftp.stub_chain(:session, :close).and_return true
          Net::SFTP.stub!(:start => @sftp)
          @sftp.should_receive(:download!).and_return true
          lambda {@sft_trasport.download('x','y')}.should_not raise_error
        end
      end

    end
      
    describe "get_csv_files_for_district(district)" do
      it "should call download for each csv_file" do
        @csv_files.each do |file|
          filename = "#{file}.csv"
          @sft_trasport.should_receive(:download).once.with(/#{filename}/,/#{filename}/)
        end
        @sft_trasport.get_csv_files
      end
    end
end
