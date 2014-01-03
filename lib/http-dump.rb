
require "http-dump/version"
require 'webmock'

class HTTPDump
  class << self
    attr_accessor :output, :quiet_format
    def enable!(options = {})
      WebMock.enable!(options)
      WebMock.allow_net_connect!(options)
      WebMock.after_request do |request_signature, response|
        output.puts self.format(request_signature, response)
      end
    end

    def disable!(options = {})
      WebMock.reset_callbacks
      WebMock.disable_net_connect!(options)
      WebMock.disable!(options)
    end

    def dump(options = {}, &block)
      enable!(options)
      block.call
    ensure
      disable!(options)
    end

    def output
      @output || STDOUT
    end

    def format(request_signature, response)
      res = []
      res << "> #{request_signature}"
      res << "< #{response.status.join(' ')}"
      response.headers.each {|key, val| res << "< #{key}: #{val}" }
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

__END__

#HTTPDump.enable!
require 'open-uri'
HTTPDump.quiet_formatt = true
HTTPDump.dump {
  open('http://example.com').read
}
open('http://example.com').read

HTTPDump.dump {
  open('http://b.hatena.ne.jp/').read
}

