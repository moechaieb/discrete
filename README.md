# Math::Discrete [![CircleCI](https://circleci.com/gh/mac-adam-chaieb/discrete.svg?style=shield)](https://circleci.com/gh/mac-adam-chaieb/discrete) [![codecov](https://codecov.io/gh/mac-adam-chaieb/discrete/branch/master/graph/badge.svg)](https://codecov.io/gh/mac-adam-chaieb/discrete) [![License](http://img.shields.io/badge/license-MIT-green.svg)](#license)

A library and DSL for discrete mathematical structures and algorithms

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'discrete'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install discrete

## To-do

This project is a work in progress and more structures and algorithms will be implemented:

Structures:
- [ ] Sets (finite and infinite)
- [ ] Set Comprehensions (for sets of all other constructs)
- [ ] Logic Propositions (first-order and second-order)
- [x] Graphs
- [x] Graph Constructs (paths)
- [ ] Natural numbers and Integer numbers
- [ ] Mappings (injections, surjections, bijections between two sets)

Algorithms:

- Graph algorithms:
  - Deterministic algorithms:
    - Breadth-first search
    - Depth-first search
    - Shortest path
    - Minimum spanning tree
    - Maximum flow
    - More TBD
  - Aproximation algorithms
    - Graph Colouring
    - Traveling salesman

Design:
 - Extract a `Math::Discrete::Structure` namespace that contains cross-structure methods and logic
 - Document every algorithm and property with relevant Wikipedia articles and papers


## Usage

#### Graphs
```ruby
# Initializing vertices and edges
first_vertex = Vertex['a'] # Or Node['a']
second_vertex = Vertex['b']
edge = Edge[first_vertex, second_vertex]

vertex_set = Vertex::Set['a', 'b', 'c', 'd'] # Or Node::Set['a', 'b', 'c', 'd']
a, b, c, d = *vertex_set
edge_set = Edge::Set[[a, b], [a, c], [a, d], [b, d], [c, d]]

# Initializing graphs
graph = Graph[]
graph << a
graph << b
graph << Edge[a,b]

# You can initialize a graph with a vertex set and an edge set
graph = Graph[vertex_set, edge_set]
# Or directly with labels
graph = Graph[['a', 'b', 'c', 'd'], ['a', 'b'], ['a', 'c'], ['a', 'd'], ['b', 'd'], ['c', 'd']]

# Weighted graphs are supported as well, by adding a third argument to the edge constructor
montreal, toronto = *Vertex::Set['Montreal', 'Toronto']
edge = Edge[montreal, toronto, 506] # The distance between MTL and the 6IX is 506 kms

map = Graph[
  ['Montreal', 'Toronto', 'Boston'],
  [
    ['Montreal', 'Toronto', 506],
    ['Toronto', 'Boston', 885],
    ['Boston', 'Montreal', 405]
  ]
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mac-adam-chaieb/discrete. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org/) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

