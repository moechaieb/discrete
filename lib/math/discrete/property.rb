class Math::Discrete::Property
  class InvalidStructureType < StandardError; end
  class NameNotUnique < StandardError; end
  class SatisfiabilityTestMissing < StandardError; end

  VALID_STRUCTURES = (Math::Discrete.constants - [:VERSION, :TypeError, :Property]).map(&:downcase).freeze

  attr_reader :name, :structure_type

  def self.build(name:, structure_type:, &block)
    unless VALID_STRUCTURES.include? structure_type
      raise InvalidStructureType, "structure_type must be one of #{VALID_STRUCTURES}"
    end

    raise SatisfiabilityTestMissing, 'you must provide a satisfiability testblock as a block' unless block_given?

    new name: name, structure_type: structure_type, satisfiability_test: block
  end

  def satisfied?(structure)
    unless Math::Discrete.const_get(structure_type.capitalize) == structure.class
      raise Math::Discrete::TypeError, "structure must of type Math::Discrete::#{structure_type.capitalize}"
    end

    result = @satisfiability_test.call structure

    unless [true, false].include? result
      raise Math::Discrete::TypeError, 'satisfiability_test must return a Boolean type'
    end

    result
  end

  private

  def initialize(name:, structure_type:, satisfiability_test:)
    @name = name.to_sym
    @structure_type = structure_type
    @satisfiability_test = satisfiability_test
  end
end
