# frozen_string_literal: true
module Puppetlabs
  module RSpecPuppet
    module ManifestMatchers
      def method_missing(method, *args, &block)
        if /^(create|contain)_/.match?(method.to_s)
          return Puppetlabs::RSpecPuppet::ManifestMatchers::CreateGeneric.new(method, *args,
                                                                    &block)
        end
        if /^have_.+_count$/.match?(method.to_s)
          return Puppetlabs::RSpecPuppet::ManifestMatchers::CountGeneric.new(nil, args[0],
                                                                  method)
        end
        return Puppetlabs::RSpecPuppet::ManifestMatchers::Compile.new if method == :compile

        super
      end
    end

    module FunctionMatchers
      def method_missing(method, *args, &block)
        return Puppetlabs::RSpecPuppet::FunctionMatchers::Run.new if method == :run

        super
      end
    end

    module TypeMatchers
      def method_missing(method, ...)
        return Puppetlabs::RSpecPuppet::TypeMatchers::CreateGeneric.new(method, ...) if method == :be_valid_type

        super
      end
    end
  end
end
