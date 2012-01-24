require 'wlang/dialect/dispatching'
require 'wlang/dialect/scoping'
require 'wlang/dialect/evaluation'
require 'wlang/dialect/tags'
module WLang
  class Dialect
    include Dialect::Dispatching
    include Dialect::Scoping
    include Dialect::Evaluation
    include Dialect::Tags

    class << self

      def factor(options = {})
        options = default_options.merge(options)
        Class.new(self).tap do |c|
          c.scoping    options[:scoping]
        end.new(options)
      end

      def default_options(options = {})
        @default_options ||= (superclass.default_options.dup rescue {})
        @default_options.merge!(options)
      end

      def compiler(options = {})
        factor(options).compiler
      end

      def compile(source, options = {})
        compiler(options).compile(source)
      end

      def to_ruby_code(source, options = {})
        compiler(options).to_ruby_code(source)
      end

      def render(source, scope = {}, buffer = "")
        compile(source).call(scope, buffer)
      end

    end

    default_options :scoping     => :strict,
                    :braces      => WLang::BRACES,
                    :autospacing => false

    attr_reader :options
    def braces; options[:braces]; end

    attr_reader :compiler

    def initialize(options = {})
      @options  = options
      @compiler = WLang::Compiler.new(self)
    end
    #private_class_method :new

  end # class Dialect
end # module WLang
