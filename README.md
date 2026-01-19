# aho_corasick

Aho-Corasick algorithm for Crystal - **O(T + M + Z)** multiple pattern string matching.

## Algorithm

The [Aho-Corasick algorithm](https://en.wikipedia.org/wiki/Aho%E2%80%93Corasick_algorithm) (1975) finds all occurrences of multiple patterns in a text simultaneously:

- **Time Complexity**: O(T + M + Z) where T = text length, M = total pattern length, Z = matches
- **Space Complexity**: O(M) for the automaton
- Used by `fgrep`, spam filters, DNA sequence analysis, and intrusion detection systems

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  aho_corasick:
    github: KarlAmort/aho_corasick
```

## Usage

```crystal
require "aho_corasick"

matcher = AhoCorasick.new %w(he she his hers)
matcher.match("ushers") do |end_pos, pattern_idx|
  puts "Found pattern #{pattern_idx} ending at position #{end_pos}"
end
# Output:
# Found pattern 1 ending at position 3  (she)
# Found pattern 0 ending at position 4  (he)
# Found pattern 3 ending at position 5  (hers)
```

## Benchmark

The algorithm demonstrates **linear time complexity in text length**:

```
===========================================================================
  AHO-CORASICK COMPLEXITY: O(T + M + Z)
  Pattern length: 5 chars
===========================================================================

Text Length |      1P |      4P |     16P |     64P |    256P |
------------|---------|---------|---------|---------|---------|
       100  |   1.7µs |   2.9µs |   4.8µs |   6.0µs |   6.0µs |
       400  |   5.0µs |  0.01ms |  0.02ms |  0.02ms |  0.02ms |
      1600  |  0.02ms |  0.05ms |  0.08ms |   0.1ms |  0.11ms |
      6400  |  0.09ms |  0.22ms |  0.26ms |  0.37ms |  0.39ms |
     25600  |  0.32ms |  0.76ms |   1.1ms |   1.5ms |   1.5ms |
    102400  |   1.3ms |   3.2ms |   4.8ms |   6.6ms |   6.9ms |

Key observations:
  - Doubling text length ≈ doubles time (linear in T)
  - Doubling patterns ≈ small constant increase (sub-linear)
  - Search time dominated by text length, not pattern count
```

Run the benchmark spec: `crystal spec spec/benchmark_spec.cr`

## How It Works

1. **Build Phase**: Constructs a trie from all patterns, then adds "failure links" that allow the automaton to efficiently backtrack on mismatches
2. **Search Phase**: Processes each character of the text exactly once, following transitions in the automaton

This is dramatically faster than naive search which would be O(T × N × P) for N patterns of length P.

## Contributing

1. Fork it (https://github.com/KarlAmort/aho_corasick/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [chenkovsky](https://github.com/chenkovsky) - original creator
- [KarlAmort](https://github.com/KarlAmort) - maintainer

## License

MIT
