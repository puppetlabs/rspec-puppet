# frozen_string_literal: true

require 'spec_helper_unit'
require 'rspec-puppet/support'

describe RSpec::Puppet::Support do
  subject(:instance) { test_class.new }

  let(:test_class) { Class.new { include RSpec::Puppet::Support } }

  describe '#guess_type_from_path' do
    {
      'spec/classes/foo_spec.rb' => :class,
      'spec/defines/bar_spec.rb' => :define,
      'spec/functions/baz_spec.rb' => :function,
      'spec/hosts/host_spec.rb' => :host,
      'spec/types/type_spec.rb' => :type,
      'spec/type_aliases/alias_spec.rb' => :type_alias,
      'spec/provider/prov_spec.rb' => :provider,
      'spec/other/unknown_spec.rb' => :unknown,
    }.each do |path, expected_type|
      it "returns :#{expected_type} for #{path}" do
        expect(instance.guess_type_from_path(path)).to eq(expected_type)
      end
    end
  end

  describe '#find_pretend_platform' do
    it 'returns :windows when operatingsystem is Windows (case-insensitive)' do
      expect(instance.find_pretend_platform('operatingsystem' => 'windows')).to eq(:windows)
    end

    it 'returns :posix when operatingsystem is Linux' do
      expect(instance.find_pretend_platform('operatingsystem' => 'Linux')).to eq(:posix)
    end

    it 'returns :windows when osfamily is windows' do
      expect(instance.find_pretend_platform('osfamily' => 'windows')).to eq(:windows)
    end

    it 'returns :posix when osfamily is Debian' do
      expect(instance.find_pretend_platform('osfamily' => 'Debian')).to eq(:posix)
    end

    it 'checks the os.name key when operatingsystem and osfamily are absent' do
      expect(instance.find_pretend_platform('os' => { 'name' => 'windows' })).to eq(:windows)
    end

    it 'checks the os.family key when os.name is absent' do
      expect(instance.find_pretend_platform('os' => { 'family' => 'windows' })).to eq(:windows)
    end

    it 'returns nil when no OS facts are present' do
      expect(instance.find_pretend_platform({})).to be_nil
    end

    it 'returns nil when the os hash has neither name nor family' do
      expect(instance.find_pretend_platform('os' => { 'release' => { 'major' => '10' } })).to be_nil
    end

    it 'prefers operatingsystem over osfamily' do
      result = instance.find_pretend_platform('operatingsystem' => 'Linux', 'osfamily' => 'windows')
      expect(result).to eq(:posix)
    end

    it 'returns nil when os value is not a Hash' do
      expect(instance.find_pretend_platform('os' => 'Linux')).to be_nil
    end
  end

  describe '#munge_facts' do
    it 'converts symbol hash keys to strings' do
      expect(instance.munge_facts(foo: 'bar')).to eq('foo' => 'bar')
    end

    it 'recursively munges nested hashes' do
      result = instance.munge_facts(os: { family: 'RedHat' })
      expect(result).to eq('os' => { 'family' => 'RedHat' })
    end

    it 'recursively munges arrays' do
      result = instance.munge_facts([{ foo: 'bar' }, 'scalar'])
      expect(result).to eq([{ 'foo' => 'bar' }, 'scalar'])
    end

    it 'returns scalar strings unchanged' do
      expect(instance.munge_facts('hello')).to eq('hello')
    end

    it 'returns integers unchanged' do
      expect(instance.munge_facts(42)).to eq(42)
    end
  end

  describe '#escape_special_chars' do
    it 'escapes $ characters' do
      expect(instance.escape_special_chars('$PATH')).to eq('\\$PATH')
    end

    it 'escapes multiple $ characters' do
      expect(instance.escape_special_chars('$A and $B')).to eq('\\$A and \\$B')
    end

    it 'returns strings without $ unchanged' do
      expect(instance.escape_special_chars('hello world')).to eq('hello world')
    end
  end

  describe '#str_from_value' do
    it 'converts a Hash to a Puppet hash literal' do
      expect(instance.str_from_value('k' => 'v')).to eq('{ "k" => "v" }')
    end

    it 'converts nested Hashes recursively' do
      result = instance.str_from_value('outer' => { 'inner' => 'val' })
      expect(result).to include('"outer"')
      expect(result).to include('"inner"')
    end

    it 'converts an Array to a Puppet array literal' do
      expect(instance.str_from_value(%w[a b])).to eq('[ "a", "b" ]')
    end

    it 'converts :default to the bare keyword "default"' do
      expect(instance.str_from_value(:default)).to eq('default')
    end

    it 'converts :undef to the bare keyword "undef"' do
      expect(instance.str_from_value(:undef)).to eq('undef')
    end

    it 'converts other symbols via their string representation' do
      expect(instance.str_from_value(:foo)).to eq('"foo"')
    end

    it 'escapes $ in string values' do
      expect(instance.str_from_value('$VAR')).to eq('"\\$VAR"')
    end

    it 'converts integers via inspect' do
      expect(instance.str_from_value(42)).to eq('42')
    end
  end

  describe '#param_str_from_hash' do
    it 'produces a Puppet parameter string for a single key' do
      expect(instance.param_str_from_hash('ensure' => 'present')).to eq('ensure => "present"')
    end

    it 'joins multiple parameters with ", "' do
      result = instance.param_str_from_hash('ensure' => 'present', 'owner' => 'root')
      expect(result).to include('ensure => "present"')
      expect(result).to include('owner => "root"')
    end

    it 'returns an empty string for an empty hash' do
      expect(instance.param_str_from_hash({})).to eq('')
    end
  end

  describe '#sanitise_resource_title' do
    it 'wraps a plain title in single quotes' do
      expect(instance.sanitise_resource_title('/tmp/foo')).to eq("'/tmp/foo'")
    end

    it 'uses inspect (double quotes) when the title contains a single quote' do
      expect(instance.sanitise_resource_title("it's")).to eq('"it\'s"')
    end
  end

  describe '#pre_cond' do
    context 'when pre_condition is not defined on the instance' do
      it 'returns nil' do
        expect(instance.pre_cond).to be_nil
      end
    end

    context 'when pre_condition is a string' do
      before { test_class.define_method(:pre_condition) { 'notify { "x": }' } }

      it 'returns the string directly' do
        expect(instance.pre_cond).to eq('notify { "x": }')
      end
    end

    context 'when pre_condition is an array of strings' do
      before { test_class.define_method(:pre_condition) { ['notify { "a": }', 'notify { "b": }'] } }

      it 'joins elements with newlines' do
        expect(instance.pre_cond).to eq("notify { \"a\": }\nnotify { \"b\": }")
      end
    end

    context 'when pre_condition is an array containing nil entries' do
      before { test_class.define_method(:pre_condition) { ['notify { "a": }', nil, 'notify { "b": }'] } }

      it 'compacts nils before joining' do
        expect(instance.pre_cond).to eq("notify { \"a\": }\nnotify { \"b\": }")
      end
    end

    context 'when pre_condition is nil' do
      before { test_class.define_method(:pre_condition) { nil } }

      it 'returns nil' do
        expect(instance.pre_cond).to be_nil
      end
    end
  end

  describe '#post_cond' do
    context 'when post_condition is not defined on the instance' do
      it 'returns nil' do
        expect(instance.post_cond).to be_nil
      end
    end

    context 'when post_condition is a string' do
      before { test_class.define_method(:post_condition) { 'notify { "y": }' } }

      it 'returns the string directly' do
        expect(instance.post_cond).to eq('notify { "y": }')
      end
    end

    context 'when post_condition is an array' do
      before { test_class.define_method(:post_condition) { ['notify { "c": }', 'notify { "d": }'] } }

      it 'joins elements with newlines' do
        expect(instance.post_cond).to eq("notify { \"c\": }\nnotify { \"d\": }")
      end
    end

    context 'when post_condition is nil' do
      before { test_class.define_method(:post_condition) { nil } }

      it 'returns nil' do
        expect(instance.post_cond).to be_nil
      end
    end
  end
end
