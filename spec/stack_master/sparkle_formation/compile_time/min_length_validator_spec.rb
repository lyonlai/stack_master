RSpec.describe StackMaster::SparkleFormation::CompileTime::MinLengthValidator do
  describe '#validate' do
    let(:error_message) { -> (error, definition) { "name:#{error} must be at least min_length:#{definition[:min_length]} characters" } }
    let(:name) {'name'}

    context 'string validation' do
      let(:validator_definition) { {type: :string, min_length: 2} }
      include_examples 'validate valid parameter', described_class, 'ab'
      include_examples 'validate valid parameter', described_class, ['ab']
      include_examples 'validate invalid parameter', described_class, 'a', ['a']
      include_examples 'validate invalid parameter', described_class, ['a'], ['a']
    end

    context 'string validation with default value' do
      let(:validator_definition) { {type: :string, min_length: 2, default: 'ab'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'string validation with multiples' do
      let(:validator_definition) { {type: :string, min_length: 2, multiple: true} }
      include_examples 'validate valid parameter', described_class, 'ab,cd'
      include_examples 'validate invalid parameter', described_class, 'a,, cd', ['a','']
    end

    context 'string validation wtih multiples and default' do
      let(:validator_definition) {  {type: :string, min_length: 2, multiple: true, default: 'ab,cd'} }
      include_examples 'validate valid parameter', described_class, nil
    end

    context 'numerical validation' do
      let(:validator_definition) { {type: :number, min_length: 2} }
      include_examples 'validate valid parameter', described_class, 'a'
    end
  end
end
