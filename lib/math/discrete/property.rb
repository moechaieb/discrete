class Math::Discrete::Property
  class NameNotUnique < StandardError; end

  attr_reader :name, :structure_class

  def self.build(name:, structure_class:, &block)
    raise NameNotUnique if name.in? ::Math::Discrete::structure_class.constantize::Properties.all.map(&:name)

    new name: name, structure_class: structure_class, satisfiability_test: block
  end

  def satisfied?(structure)
    raise Math::Discrete::TypeError, "structure must of type #{structure_class}" unless structure_class == structure.class

    result = @satisfiability_test.call structure

    raise Math::Discrete::TypeError, 'satisfiability_test must return a Boolean type' unless !!result == result

    result
  end

  private

  def initialize(name:, structure_class:, satisfiability_test:)
    @name = name.to_sym
    @structure_class = structure_class
    @satisfiability_test = satisfiability_test
  end
end
