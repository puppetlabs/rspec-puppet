# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet/coverage'
require 'rspec-puppet/support'

describe RSpec::Puppet::Coverage do
  subject { described_class.new }

  # Save and restore the global coverage object so that these tests don't
  # affect the actual spec coverage
  before(:all) do
    @saved = described_class.instance
    described_class.instance = described_class.new
  end

  after(:all) do
    described_class.instance = @saved
  end

  describe 'filtering' do
    it 'filters boilerplate catalog resources by default' do
      expect(subject.filters).to eq %w[Stage[main] Class[Settings] Class[main] Node[default]]
    end

    it 'can add additional filters' do
      subject.add_filter('notify', 'ignore me')
      expect(subject.filters).to include('Notify[ignore me]')

      subject.add_filter('foo::bar', 'ignore me')
      expect(subject.filters).to include('Foo::Bar[ignore me]')

      subject.add_filter('class', 'foo::bar')
      expect(subject.filters).to include('Class[Foo::Bar]')
    end

    describe 'regular expression based filtering' do
      [
        [/test.*/, /\ANotify\[.*test.*.*\]\z/],
        [/ignore[0-9]+/, /\ANotify\[.*ignore[0-9]+.*\]\z/],
        [/\Astart_with/, /\ANotify\[start_with.*\]\z/],
        [/\Aanchored\Z/, /\ANotify\[anchored\]\z/],
        [/end_with\Z/, /\ANotify\[.*end_with\]\z/],
        [/end_with\z/, /\ANotify\[.*end_with\]\z/],
        [/end_with$/, /\ANotify\[.*end_with\]\z/],
        [/escapism\$/, /\ANotify\[.*escapism\$.*\]\z/],
        [/escapism\\Z/, /\ANotify\[.*escapism\\Z.*\]\z/],
        [/escapism\\\\\Z/, /\ANotify\[.*escapism\\\\\]\z/],
        [/escapism\\\\$/, /\ANotify\[.*escapism\\\\\]\z/],
        [/escapism\\\\\$/, /\ANotify\[.*escapism\\\\\$.*\]\z/],
        [/escapism\\\\\\\$/, /\ANotify\[.*escapism\\\\\\\$.*\]\z/],
      ].each do |input, filter|
        it "maps #{input} to #{filter}" do
          subject.add_filter_regex('notify', input)
          expect(subject.filters_regex).to include(filter)
        end
      end
    end

    it 'filters resources based on the resource title' do
      # TODO: this is evil and uses duck typing on `#to_s` to work.
      fake_resource = 'Stage[main]'
      expect(subject.filtered?(fake_resource)).to be
    end
  end

  describe 'adding resources that could be covered' do
    it "adds resources that don't exist and aren't filtered" do
      expect(subject.add('Notify[Add me]')).to be
    end

    it 'ignores resources that have been filtered' do
      subject.add_filter('notify', 'ignore me')
      expect(subject.add('Notify[ignore me]')).not_to be

      subject.add_filter('foo::bar', 'ignore me')
      expect(subject.add('Foo::Bar[ignore me]')).not_to be

      subject.add_filter('class', 'foo::bar')
      expect(subject.add('Class[Foo::Bar]')).not_to be
    end

    it 'ignores resources that have been regex filtered' do
      subject.add_filter_regex('notify', /test.*/)
      expect(subject.add('Notify[testing123]')).not_to be
    end

    it 'ignores resources that have already been added' do
      subject.add('Notify[Ignore the duplicate]')
      expect(subject.add('Notify[Ignore the duplicate]')).not_to be
    end
  end

  describe 'getting coverage results' do
    let(:touched) { %w[First Second Third Fourth Fifth] }
    let(:report) { subject.results }
    let(:untouched) { %w[Sixth Seventh Eighth Nineth] }

    before do
      touched.each do |title|
        subject.add("Notify[#{title}]")
        subject.cover!("Notify[#{title}]")
      end
      untouched.each do |title|
        subject.add("Notify[#{title}]")
      end
    end

    it 'counts the total number of resources' do
      expect(report[:total]).to eq 9
    end

    it 'counts the number of touched resources' do
      expect(report[:touched]).to eq 5
    end

    it 'counts the number of untouched resources' do
      expect(report[:untouched]).to eq 4
    end

    it 'counts the coverage percentage' do
      expect(report[:coverage]).to eq '55.56'
    end

    it 'includes all resources and their status' do
      resources = report[:resources]
      touched.each do |name|
        expect(resources["Notify[#{name}]"]).to eq(touched: true)
      end
      untouched.each do |name|
        expect(resources["Notify[#{name}]"]).to eq(touched: false)
      end
    end

    context 'when there are no resources' do
      let(:touched) { [] }
      let(:untouched) { [] }

      it 'reports 100% coverage' do
        expect(report[:coverage]).to eq '100.00'
      end
    end
  end

  describe '#coverage_test' do
    context 'with a non-numeric coverage_desired' do
      it 'prints an informative error' do
        expect { subject.coverage_test('not_a_number', { coverage: '80.00' }) }
          .to output(/must be 0 <= x <= 100/).to_stdout
      end
    end

    context 'with coverage_desired > 100' do
      it 'prints an informative error' do
        expect { subject.coverage_test(101, { coverage: '80.00' }) }
          .to output(/must be 0 <= x <= 100/).to_stdout
      end
    end

    context 'with coverage_desired < 0' do
      it 'prints an informative error' do
        expect { subject.coverage_test(-1, { coverage: '80.00' }) }
          .to output(/must be 0 <= x <= 100/).to_stdout
      end
    end
  end

  describe '#load_results' do
    let(:result_file) do
      file = Tempfile.new('coverage')
      data = { 'Notify[touched]' => { 'touched' => true }, 'Notify[untouched]' => { 'touched' => false } }
      file.write(data.to_json)
      file.flush
      file
    end

    after do
      result_file.close
      result_file.unlink
    end

    it 'adds touched and untouched resources from a JSON file' do
      subject.load_results(result_file.path)
      result = subject.results
      expect(result[:touched]).to eq(1)
      expect(result[:untouched]).to eq(1)
    end
  end

  describe '#load_filters' do
    it 'appends filters loaded from a JSON file' do
      require 'tempfile'
      require 'json'
      file = Tempfile.new('filters')
      file.write(['Notify[x]', 'File[y]'].to_json)
      file.flush

      subject.load_filters(file.path)
      expect(subject.filters).to include('Notify[x]', 'File[y]')
    ensure
      file.close
      file.unlink
    end

    it 'removes already-added resources that match the new filters' do
      require 'tempfile'
      require 'json'
      subject.add('Notify[x]')
      file = Tempfile.new('filters')
      file.write(['Notify[x]'].to_json)
      file.flush

      subject.load_filters(file.path)
      expect(subject.results[:total]).to eq(0)
    ensure
      file.close
      file.unlink
    end
  end

  describe '#load_filters_regex' do
    it 'appends regex filters loaded from a JSON file' do
      require 'tempfile'
      require 'json'
      file = Tempfile.new('filters_regex')
      file.write(['test.*'].to_json)
      file.flush

      subject.load_filters_regex(file.path)
      expect(subject.filters_regex).not_to be_empty
      expect(subject.filters_regex.first).to be_a(Regexp)
    ensure
      file.close
      file.unlink
    end

    it 'removes already-added resources that match the new regex filters' do
      require 'tempfile'
      require 'json'
      subject.add('Notify[testing123]')
      file = Tempfile.new('filters_regex')
      file.write(['test.*'].to_json)
      file.flush

      subject.load_filters_regex(file.path)
      expect(subject.results[:total]).to eq(0)
    ensure
      file.close
      file.unlink
    end
  end

  describe '#save_results' do
    it 'writes coverage, filter, and regex-filter files to the temp directory' do
      require 'digest'
      require 'json'
      slug = "#{Digest::MD5.hexdigest(Dir.pwd)}-#{Process.pid}"
      coverage_file    = File.join(Dir.tmpdir, "rspec-puppet-coverage-#{slug}")
      filter_file      = File.join(Dir.tmpdir, "rspec-puppet-filter-#{slug}")
      regex_filter_file = File.join(Dir.tmpdir, "rspec-puppet-filter_regex-#{slug}")

      subject.add('Notify[saved]')
      subject.save_results

      expect(File.exist?(coverage_file)).to be(true)
      expect(JSON.parse(File.read(coverage_file)).keys).to include('Notify[saved]')
    ensure
      [coverage_file, filter_file, regex_filter_file].each { |f| File.delete(f) if f && File.exist?(f) }
    end
  end

  describe '#merge_results' do
    it 'loads all matching coverage files and removes them' do
      require 'digest'
      require 'json'
      slug = "#{Digest::MD5.hexdigest(Dir.pwd)}-99999999"
      coverage_file = File.join(Dir.tmpdir, "rspec-puppet-coverage-#{slug}")
      File.write(coverage_file, { 'Notify[merged]' => { 'touched' => true } }.to_json)

      subject.merge_results
      expect(subject.results[:touched]).to eq(1)
      expect(File.exist?(coverage_file)).to be(false)
    ensure
      File.delete(coverage_file) if coverage_file && File.exist?(coverage_file)
    end
  end

  describe '#merge_filters' do
    let(:slug) { "#{Digest::MD5.hexdigest(Dir.pwd)}-99999998" }
    let(:filter_file) { File.join(Dir.tmpdir, "rspec-puppet-filter-#{slug}") }
    let(:regex_filter_file) { File.join(Dir.tmpdir, "rspec-puppet-filter_regex-#{slug}") }

    before do
      File.write(filter_file, ['Notify[merged_filter]'].to_json)
      File.write(regex_filter_file, ['merged.*'].to_json)
    end

    after { [filter_file, regex_filter_file].each { |f| FileUtils.rm_f(f) } }

    it 'loads and removes matching filter and regex-filter files' do
      subject.merge_filters
      expect(subject.filters).to include('Notify[merged_filter]')
      expect(subject.filters_regex.map(&:source)).to include(a_string_including('merged'))
      expect(File.exist?(filter_file)).to be(false)
      expect(File.exist?(regex_filter_file)).to be(false)
    end
  end

  context 'with parallel tests' do
    before do
      allow(subject).to receive(:parallel_tests?).and_return(true)
    end

    describe 'getting coverage results' do
      let(:touched) { %w[First Second Third Fourth Fifth] }
      let(:untouched) { %w[Sixth Seventh Eighth Nineth] }

      before do
        touched.each do |title|
          subject.add("Notify[#{title}]")
          subject.cover!("Notify[#{title}]")
        end

        untouched.each do |title|
          subject.add("Notify[#{title}]")
        end

        allow(subject).to receive(:coverage_test)
      end

      it 'outputs report' do
        expect { subject.run_report }.to output(/coverage report/i).to_stdout
      end
    end
  end
end
