require 'json'
require 'spec_helper'
require 'fluent/stackprof'

describe Fluent::Stackprof do
  CONFIG_PATH = File.join(File.dirname(__FILE__), 'fluent.conf')
  BIN_DIR = File.join(ROOT, 'bin')
  OUTPUT_FILE = File.join(File.dirname(__FILE__), 'test.dump')

  context '#parse_options' do
    it 'incorrect subcommand' do
      expect { Fluent::Stackprof.new.parse_options(['foo']) }.to raise_error(OptionParser::InvalidOption)
    end

    it 'correct measure_mode' do
      expect { Fluent::Stackprof.new.parse_options(['start', '-m', 'cpu']) }.not_to raise_error
    end

    it 'incorrect measure_mode' do
      expect { Fluent::Stackprof.new.parse_options(['start', '-m', 'foo']) }.to raise_error(OptionParser::InvalidOption)
    end
  end

  context 'profiling' do
    before :all do
      @fluentd_pid = spawn('fluentd', '-c', CONFIG_PATH, out: '/dev/null')
      sleep 2

      system("#{File.join(BIN_DIR, 'fluent-stackprof')} start -m wall")
      sleep 2

      system("#{File.join(BIN_DIR, 'fluent-stackprof')} stop -o #{OUTPUT_FILE}")
      sleep 1
    end

    after :all do
      Process.kill(:TERM, @fluentd_pid)
      Process.waitall
    end

    it 'should output' do
      expect(File.size?(OUTPUT_FILE)).to be_truthy
    end
  end
end
