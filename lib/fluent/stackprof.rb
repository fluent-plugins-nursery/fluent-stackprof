require 'optparse'
require 'drb/drb'

module Fluent
  class Stackprof
    def parse_options(argv = ARGV)
      op = OptionParser.new
      op.banner += ' <start/stop> [output_file]'

      (class<<self;self;end).module_eval do
        define_method(:usage) do |msg|
          puts op.to_s
          puts "error: #{msg}" if msg
          exit 1
        end
      end

      opts = {
        host: '127.0.0.1',
        port: 24230,
        unix: nil,
        command: nil, # start or stop
        output: '/tmp/fluent-stackprof.dump',
        mode: 'cpu',
      }

      op.on('-h', '--host HOST', "fluent host (default: #{opts[:host]})") {|v|
        opts[:host] = v
      }

      op.on('-p', '--port PORT', "debug_agent tcp port (default: #{opts[:host]})", Integer) {|v|
        opts[:port] = v
      }

      op.on('-u', '--unix PATH', "use unix socket instead of tcp") {|v|
        opts[:unix] = v
      }

      op.on('-o', '--output PATH', "output path (default: #{opts[:output]})") {|v|
        opts[:output] = v
      }

      op.on('-m', '--mode MODE', "stackprof measure mode (default: #{opts[:mode]})") {|v|
        opts[:mode] = v
      }

      op.parse!(argv)

      opts[:command] = argv.shift
      unless %w[start stop].include?(opts[:command])
        raise OptionParser::InvalidOption.new("`start` or `stop` must be specified as the 1st argument")
      end

      modes = %w[wall cpu object custom]
      unless modes.include?(opts[:mode])
        raise OptionParser::InvalidOption.new("-m allows one of #{modes.join(', ')}")
      end

      opts
    end

    def run
      begin
        opts = parse_options
      rescue OptionParser::InvalidOption => e
        usage e.message
      end

      unless opts[:unix].nil?
        uri = "drbunix:#{opts[:unix]}"
      else
        uri = "druby://#{opts[:host]}:#{opts[:port]}"
      end

      $remote_engine = DRb::DRbObject.new_with_uri(uri)

      case opts[:command]
      when 'start'
        remote_code = <<-CODE
        require 'stackprof'
        StackProf.start(mode: :#{opts[:mode]})
        CODE
      when 'stop'
        remote_code = <<-"CODE"
        StackProf.stop
        StackProf.results('#{opts[:output]}')
        CODE
      end

      puts remote_code
      $remote_engine.method_missing(:instance_eval, remote_code)

      case opts[:command]
      when 'start'
        $stdout.puts 'fluent-stackprof: started'
      when 'stop'
        $stdout.puts "fluent-stackprof: outputs to #{opts[:output]}"
      end
    end
  end
end
