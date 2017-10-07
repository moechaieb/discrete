class Math::Discrete::Property
  class InvalidStructureType < StandardError; end
  class SatisfiabilityTestMissing < StandardError; end

  attr_reader :name, :adjective

  def self.build(name:, adjective:, &block)
    raise SatisfiabilityTestMissing, 'you must provide a satisfiability test as a block' unless block_given?

    new name: name, adjective: adjective, satisfiability_test: block
  end

  def satisfied?(structure)

    result = @satisfiability_test.call structure

    raise TypeError, 'satisfiability_test must return a Boolean type' unless [true, false].include? result

    result
  end

  private_class_method :new
  def initialize(name:, adjective:, satisfiability_test:)
    @name = name.to_sym
    @adjective = adjective.to_sym
    @satisfiability_test = satisfiability_test
  end
end
