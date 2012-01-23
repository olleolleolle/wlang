require 'wlang/compiler/parser'
require 'wlang/compiler/filter'
require 'wlang/compiler/dialect_enforcer'
require 'wlang/compiler/autospacing'
require 'wlang/compiler/proc_call_removal'
require 'wlang/compiler/to_ruby_abstraction'
require 'wlang/compiler/multi_flattener'
require 'wlang/compiler/static_merger'
require 'wlang/compiler/to_ruby_code'
module WLang
  class Compiler

    attr_reader :dialect

    def initialize(dialect)
      @dialect = dialect
    end

    def options
      dialect.options
    end

    def compile(source)
      case source
      when Template
        source
      when Proc
        Template.new(@dialect, source)
      else
        code = to_ruby_code(source)
        proc = eval(code, TOPLEVEL_BINDING)
        Template.new(@dialect, proc)
      end
    end

    def to_ruby_code(source)
      engine.call(source)
    end

    def ast(source)
      parser.new.call(source)
    end

    def parser
      Class.new(Temple::Engine).tap{|c|
        c.use Parser
        c.use DialectEnforcer, :dialect => @dialect
        c.use Autospacing if options[:autospacing]
      }
    end

    def engine(gencode = true)
      Class.new(Temple::Engine).tap{|c|
        c.use Parser
        c.use DialectEnforcer, :dialect => @dialect
        c.use Autospacing if options[:autospacing]
        c.use ProcCallRemoval
        c.use ToRubyAbstraction
        c.use MultiFlattener
        c.use StaticMerger
        c.use ToRubyCode if gencode
      }.new
    end

  end # class Compiler
end # module WLang
