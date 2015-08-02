# coding: utf-8
require 'spec_helper'
require 'uri'
require 'open-uri'
require 'stringio'

describe HTTPDump do
  let!(:output) { StringIO.new }

  before(:each) do
    HTTPDump.disable!
    HTTPDump.output = output
    HTTPDump.output_encoding = nil
  end

  after(:each) do
    HTTPDump.quiet_format = false
  end

  it 'should have a version' do
    expect(HTTPDump::VERSION).to be
  end

  context '.dump' do
    it 'http://example.com/' do
      stub_request(:get, 'http://example.com/').to_return({:body => 'EXAMPLE!', :status => 200}).times(2)
      output.should_receive(:puts).with(/X-My-Header.*foo.*200.*EXAMPLE!/m).once
      HTTPDump.dump {
        open('http://example.com/', "X-My-Header" => "foo").read
      }
      open('http://example.com/', "X-My-Header" => "foo").read
    end

    it 'http://example.com/ use Net::HTTP.get' do
      stub_request(:get, 'http://example.com/').to_return({:body => 'EXAMPLE!', :status => 200}).times(2)
      output.should_receive(:puts).with(/200.*EXAMPLE!/m).once
      HTTPDump.dump {
        Net::HTTP.get(URI('http://example.com/'))
      }
      Net::HTTP.get(URI('http://example.com/'))
    end

    it 'http://example.com/ with quiet_format' do
      HTTPDump.quiet_format = true
      stub_request(:get, 'http://example.com/').to_return({:body => 'A' * 10000, :status => 200}).times(1)
      output.should_receive(:puts).with(/10000/m).once
      HTTPDump.dump {
        open('http://example.com/', "X-My-Header" => "foo").read
      }
    end
  end

  context '.output_encoding=' do
    let(:request_header_with_utf8) { {"X-My-Header" => "日本語".force_encoding("utf-8")} }
    let(:response_body_with_ascii) { "日本語".force_encoding("ascii") }

    it 'raises encoding error if encoding of request and response is not matched and output_encoding is not set' do
      expect {
        stub_request(:get, 'http://example.com/').to_return({:body => response_body_with_ascii, :status => 200}).times(1)
        HTTPDump.dump {
          open('http://example.com/', request_header_with_utf8)
        }
      }.to raise_error(Encoding::CompatibilityError)
    end

    it 'does not raise encoding error if encoding of request and response is not matched but output_encoding is set' do
      expect {
        HTTPDump.output_encoding = "utf-8"
        stub_request(:get, 'http://example.com/').to_return({:body => response_body_with_ascii, :status => 200}).times(1)
        HTTPDump.dump {
          open('http://example.com/', request_header_with_utf8)
        }
      }.not_to raise_error
    end
  end

  it '.enable!' do
    HTTPDump.enable!
    HTTPDump.should_not_receive(:enable!)
    HTTPDump.should_not_receive(:disable!)

    stub_request(:get, 'http://example.com/').to_return({:body => 'EXAMPLE!', :status => 200}).times(2)
    output.should_receive(:puts).with(/X-My-Header.*foo.*200.*EXAMPLE!/m).twice
    HTTPDump.dump {
      open('http://example.com/', "X-My-Header" => "foo").read
    }
    open('http://example.com/', "X-My-Header" => "foo").read
  end

  it '.disable!' do
    HTTPDump.enable!
    HTTPDump.disable!
    stub_request(:get, 'http://example.com/').to_return({:body => 'EXAMPLE!', :status => 200}).times(1)
    output.should_not_receive(:puts).with(/X-My-Header.*foo.*200.*EXAMPLE!/m)
    open('http://example.com/', "X-My-Header" => "foo").read
  end
end
