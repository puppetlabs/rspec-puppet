# frozen_string_literal: true

module RSpec::Puppet
  module ManifestMatchers
    def method_missing(method, *args, &)
      if /^(create|contain)_/.match?(method.to_s)
        return RSpec::Puppet::ManifestMatchers::CreateGeneric.new(method, *args,
                                                                  &)
      end
      if /^have_.+_count$/.match?(method.to_s)
        return RSpec::Puppet::ManifestMatchers::CountGeneric.new(nil, args[0],
                                                                 method)
      end
      return RSpec::Puppet::ManifestMatchers::Compile.new if method == :compile

      super
    end
  end

  module FunctionMatchers
    def method_missing(method, *args, &)
      return RSpec::Puppet::FunctionMatchers::Run.new if method == :run

      super
    end
  end

  module TypeMatchers
    def method_missing(method, ...)
      return RSpec::Puppet::TypeMatchers::CreateGeneric.new(method, ...) if method == :be_valid_type

      super
    end
  end
end
