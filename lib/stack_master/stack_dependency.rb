module StackMaster
  class StackDependency
    StackOutputNotFound = Class.new(StandardError)

    def initialize(stack_definition, config)
      @stack_definition = stack_definition
      @config = config
    end

    def outdated_stacks
      @config.stacks.select do |stack|
        dependent_stack = Stack.find(stack.region, stack.stack_name)
        next unless dependent_stack
        parameters = ParameterLoader.load(stack.parameter_files)
        any_stack_output_outdated?(parameters, dependent_stack) || any_stack_outputs_outdated?(parameters, dependent_stack)
      end
    end

    private

    def any_stack_output_outdated?(params, stack)
      params.any? do |_, value|
        value['stack_output'] &&
          value['stack_output'].gsub('_', '-') =~ %r(#{@stack_definition.stack_name}/) &&
          outdated?(stack, value['stack_output'].split('/').last)
      end
    end

    def any_stack_outputs_outdated?(params, stack)
      params.any? do |key, value|
        value['stack_outputs'] &&
          value['stack_outputs'].any? do |output|
            index = value['stack_outputs'].find_index(output)
            dependent_parameter = stack_parameter(stack, key)
            this_output_value = dependent_parameter.split(',')[index]
            output.gsub('_', '-') =~ %r(#{@stack_definition.stack_name}/) &&
              output_value(output.split('/').last.camelize) != this_output_value
          end
      end
    end

    def outdated?(dependent_stack, output_key)
      stack_output = output_value(output_key.camelize)
      dependent_input = stack_parameter(dependent_stack, output_key)
      dependent_input != stack_output
    end

    def stack_parameter(stack, key)
      stack.parameters[key.camelize]
    end

    def output_value(key)
      output_hash = updated_stack.outputs.select { |output_type| output_type[:output_key] == key }
      if output_hash && ! output_hash.empty?
        output_hash.first[:output_value]
      else
        raise StackOutputNotFound, "Stack exists (#{updated_stack.stack_name}), but output does not: #{key}"
      end
    end

    def updated_stack
      @stack ||= Stack.find(@stack_definition.region, @stack_definition.stack_name)
    end
  end
end
