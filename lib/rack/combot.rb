require "rack/combot/config"
require "pathname"
require 'uri'

module Rack
  class Combot
    def self.configure(*args)
      new(*args)
    end

    MIME_TYPES = {
      "js"  => "css/javascript",
      "css" => "text/css"
    }

    def initialize(options = {})
      root = Pathname.new(options[:root] || Dir.pwd)
      @config = Rack::Combot::Config.new(root)
    end

    # rack request handler
    def call(env)
      params      = env["QUERY_STRING"]
      file_names  = params.split("&")
      extention   = file_names[0].split(".").last

      combo = Combination.new(@config.root, file_names).combine

      [200, {"Content-Type" => MIME_TYPES[extention]}, combo]
    end

    class Combination
      def initialize(root, file_names)
        @file_contents = []

        file_names.each do |file_name|
          @file_contents << ::File.open("#{root}/#{file_name}", 'r') { |f| f.read }
        end
      end

      def combine
        @combo ||= @file_contents.join
      end
    end

  end
end
