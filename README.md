# HTTPDump

[![Build Status](https://travis-ci.org/hotchpotch/http-dump.png?branch=master)](https://travis-ci.org/hotchpotch/http-dump)

Dump http request use [WebMock](https://github.com/bblimke/webmock).

Supported HTTP libraries = [WebMock supported liraries](https://github.com/bblimke/webmock#supported-http-libraries), Net::HTTP, HTTPParty, HTTPClient, Excon, more...

```
$ gem install http-dump
```

## Usage

### HTTPDump.dump(options={}, &block)

```ruby
require 'net/http'
require 'uri'
require 'http-dump'

HTTPDump.dump {
    Net::HTTP.get(URI('http://example.com'))
}
```

#### result

```
> GET http://example.com/ with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'example.com', 'User-Agent'=>'Ruby'}
< 200 OK
< Accept-Ranges: bytes
< Cache-Control: max-age=604800
< Content-Type: text/html
< Date: Fri, 03 Jan 2014 13:42:51 GMT
< Etag: "359670651"
< Expires: Fri, 10 Jan 2014 13:42:51 GMT
< Last-Modified: Fri, 09 Aug 2013 23:54:35 GMT
< Server: ECS (sjc/4FB4)
< X-Cache: HIT
< X-Ec-Custom-Error: 1
< Content-Length: 1270
<
<!doctype html>
<html>
<head>
  <title>Example Domain</title>
... more ...
```

### HTTPDump.enable!(options={}), disable!(options={})

```ruby
require 'open-uri'
require 'http-dump'

HTTPDump.enable!
open('http://example.com').read
HTTPDump.disable!
```

#### result

```
> GET http://example.com/ with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'example.com', 'User-Agent'=>'Ruby'}
< 200 OK
... more ...
```

### HTTPDump.quiet_format

```ruby
HTTPDump.quiet_format = true
HTTPDump.dump {
    Net::HTTP.get(URI('http://example.com'))
}
```

#### result

```
> GET http://example.com/ with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'example.com', 'User-Agent'=>'Ruby'}
< 200 OK
< Accept-Ranges: bytes
< Cache-Control: max-age=604800
< Content-Type: text/html
< Date: Fri, 03 Jan 2014 14:06:43 GMT
< Etag: "359670651"
< Expires: Fri, 10 Jan 2014 14:06:43 GMT
< Last-Modified: Fri, 09 Aug 2013 23:54:35 GMT
< Server: ECS (sjc/4FB4)
< X-Cache: HIT
< X-Ec-Custom-Error: 1
< Content-Length: 1270
<
<!doctype html>
* ... Response body is 1270 bytes.
</html>

```

### HTTPDump.output=, output

```ruby
HTTPDump.output #=> #<IO:<STDOUT>> (default output)
HTTPDump.output = STDERR
HTTPDump.dump {
    Net::HTTP.get(URI('http://example.com')) # dump to STDERR
}

require 'logger'
logger = Logger.new(STDOUT)
logger.instance_eval { class << self; alias_method :puts, :info; end }
HTTPDump.output = logger
HTTPDump.dump {
    Net::HTTP.get(URI('http://example.com')) # dump to logger
}
```

### HTTPDump.output_encoding=

In some cases, encoding of request and response is not matched and it causes `Encoding::CompatibilityError`.

`HTTPDump.output_encoding=` may resolve the issue.

```ruby
HTTPDump.output_encoding = "utf-8"
```

### http-dump/enable

```sh
$ ruby -r'net/http' -r'uri' -r'http-dump/enable' -e 'Net::HTTP.get(URI("http://example.com/"))'
> GET http://example.com/ with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'example.com', 'User-Agent'=>'Ruby'}
< 200 OK
...
```

#### on Rails

```
# in Gemfile

group :development do
  gem 'http-dump', require: ENV['HTTP_DUMP_ENABLE'] ? 'http-dump/enable' : 'http-dump'
end
```

```
HTTP_DUMP_ENABLE=1 bundle exec rails s
```

## Installation

Add this line to your application's Gemfile:

    gem 'http-dump'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http-dump

