# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

# /dataservice/bundle_loggers/7/bundle_contents.bundle

class BundleContent
  
  REQUEST_METHOD = 'REQUEST_METHOD'.freeze unless defined?(REQUEST_METHOD)
  POST = 'POST'.freeze unless defined?(POST)
  PATH_INFO = 'PATH_INFO'.freeze unless defined?(PATH_INFO)
  
  POST_BODY = 'rack.input'.freeze unless defined?(POST_BODY)
  
  def self.call(env)
    bundle_logger_id = env[PATH_INFO][/\/dataservice\/bundle_loggers\/(\d+)\/bundle_contents\.bundle/, 1]
    if env[REQUEST_METHOD] == POST && bundle_logger_id && bundle_logger = ::Dataservice::BundleLogger.find(bundle_logger_id)
      body = env[POST_BODY].read
      bundle_logger.end_bundle( { :body => body} )
      bundle_content = bundle_logger.bundle_contents.last
      digest = Digest::MD5.hexdigest(body)
      [201, 
        { 'Content-Type' => 'text/xml', 
          'Last-Modified' => bundle_content.created_at.httpdate, 
          'Content-Length' => '0',
          'Content-MD5' => digest },
        []
      ]
    else
      [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
    end
  ensure
    # If we accessed ActiveRecord then release the connections back to the pool. 
    # see: http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
    ActiveRecord::Base.clear_active_connections! if bundle_logger_id
  end
end
