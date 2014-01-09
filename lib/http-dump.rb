
require "http-dump/version"

class HTTPDump
  class << self
    attr_accessor :output, :quiet_format
    def enable!(options = {})
      require 'webmock'
      WebMock.enable!(options)
      WebMock.allow_net_connect!(options)
      WebMock.after_request do |request_signature, response|
        output.puts self.format(request_signature, response)
      end
      @enabled = true
    end

    def disable!(options = {})
      WebMock.reset_callbacks
      WebMock.disable!(options)
      @enabled = false
    end

    def dump(options = {}, &block)
      enabled = @enabled
      enable!(options) unless enabled
      block.call
    ensure
      disable!(options) unless enabled
    end

    def output
      @output || STDOUT
    end

    def format(request_signature, response)
      res = []
      res << "> #{request_signature}"
      res << "< #{response.status.join(' ')}"
      response.headers.each {|key, val| res << "< #{key}: #{val}" } if response.headers
      body = response.body
      unless body.empty?
        res << "<"
        if quiet_format && body.size > 100
          head = body[0..50]
          res << head.split("\n")[0]
          res << "* ... Response body is #{body.bytesize} bytes."
          tail = body[-50..-1]
          res << tail.split("\n")[-1]
        else
          res << body
        end
      end
      res.join("\n")
    end
  end
end

