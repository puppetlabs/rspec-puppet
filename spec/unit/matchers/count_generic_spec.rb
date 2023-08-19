# frozen_string_literal: true

require 'spec_helper_unit'

describe RSpec::Puppet::ManifestMatchers::CountGeneric do
  subject(:matcher) { described_class.new(type, expected, method) }

  let(:actual) do
    -> { instance_double(Puppet::Resource::Catalog, resources: resource_objects) }
  end

  let(:resource_objects) do
    resources.map do |type, title|
      instance_double(Puppet::Resource, ref: "#{type}[#{title}]", type: type)
    end
  end

  let(:resources) { [] }
  let(:type) { nil }
  let(:expected) { 0 }
  let(:method) { nil }
  let(:default_resources) do
    [
      %w[Class main],
      %w[Class Settings],
      %w[Stage main]
    ]
  end

  it 'is not a diffable matcher' do
    pending 'method not implemented'
    expect(matcher).not_to be_diffable
  end

  describe '#initialize' do
    context 'when initialised with a specified type' do
      context 'and the type is a single namespace segment' do
        let(:type) { 'class' }

        it 'capitalises the type' do
          expect(matcher.resource_type).to eq('Class')
        end
      end

      context 'and the type is multiple namespaced segments' do
        let(:type) { 'test::type' }

        it 'capitalises each segment of the type' do
          pending 'bug - not implemented'
          expect(matcher.resource_type).to eq('Test::Type')
        end
      end
    end

    context 'when initialised with a method name via method_missing' do
      let(:type) { nil }

      context 'and the type is a single namespace segment' do
        let(:method) { 'have_class_resource_count' }

        it 'extracts the type from the method name and capitalises it' do
          expect(matcher.resource_type).to eq('Class')
        end
      end

      context 'and the type is multiple namespaced segments' do
        let(:method) { 'have_test__type_resource_count' }

        it 'extracts the type from the method name and capitalises each segment' do
          expect(matcher.resource_type).to eq('Test::Type')
        end
      end
    end
  end

  describe '#description' do
    subject(:description) { matcher.description }

    context 'when counting classes in the catalogue' do
      let(:type) { 'class' }

      context 'and only a single class is expected' do
        let(:expected) { 1 }

        it 'describes an expectation of a singular class' do
          expect(description).to eq('contain exactly 1 class')
        end
      end

      context 'and more than one class is expected' do
        let(:expected) { 2 }

        it 'describes an expectation of plural classes' do
          expect(description).to eq('contain exactly 2 classes')
        end
      end
    end

    context 'when counting all resources' do
      let(:type) { 'resource' }

      context 'and only a single resource is expected' do
        let(:expected) { 1 }

        it 'describes an expectation of a singular resource' do
          expect(description).to eq('contain exactly 1 resource')
        end
      end

      context 'and more than one resource is expected' do
        let(:expected) { 2 }

        it 'describes an expectation of plural resources' do
          expect(description).to eq('contain exactly 2 resources')
        end
      end
    end

    context 'when counting resources of a particular type' do
      let(:type) { 'exec' }

      context 'and only a single resource is expected' do
        let(:expected) { 1 }

        it 'describes an expectation of a singular resource type' do
          expect(description).to eq('contain exactly 1 Exec resource')
        end
      end

      context 'and more than one resource is expected' do
        let(:expected) { 2 }

        it 'describes an expectation of plural resources of a type' do
          expect(description).to eq('contain exactly 2 Exec resources')
        end
      end
    end
  end

  describe '#matches?' do
    subject(:match) { matcher.matches?(actual) }

    context 'when counting all resources' do
      let(:type) { 'resource' }
      let(:expected) { 0 }

      let(:resources) do
        [
          ['Class', 'test'],
          ['Node', 'testhost.test.com']
        ]
      end

      it 'does not include Class, Node or default resources in the count' do
        expect(match).to be_truthy
      end

      context 'and the catalogue contains a number of countable resources' do
        let(:resources) do
          super() + [
            ['File', '/tmp/testfile'],
            ['Exec', 'some command'],
            ['Service', 'a service']
          ]
        end

        context 'and the expected value matches the resource count' do
          let(:expected) { 3 }

          it 'returns true' do
            expect(match).to be_truthy
          end
        end

        context 'and the expected value does not match the resource count' do
          let(:expected) { 4 }

          it 'returns false' do
            expect(match).to be_falsey
          end
        end
      end
    end

    context 'and counting resources of a particular type' do
      let(:type) { 'class' }
      let(:expected) { 1 }
      let(:resources) do
        [
          %w[Class test],
          %w[File testfile]
        ]
      end

      it 'does not include default resources of that type in the resource count' do
        expect(match).to be_truthy
      end
    end
  end

  describe '#failure_message' do
    let(:expected) { 999 }
    let(:type) { 'class' }

    it 'provides the description of the failure and the actual value' do
      matcher.matches?(actual)
      msg = 'expected that the catalogue would contain exactly 999 classes but it contains 0'
      expect(matcher.failure_message).to eq(msg)
    end
  end

  describe '#failure_message_when_negated' do
    let(:expected) { 999 }
    let(:type) { 'class' }

    it 'provides the description of the failure' do
      matcher.matches?(actual)
      msg = 'expected that the catalogue would not contain exactly 999 classes but it does'
      expect(matcher.failure_message_when_negated).to eq(msg)
    end
  end
end
