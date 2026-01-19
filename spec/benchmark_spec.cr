require "./spec_helper"

# Aho-Corasick Algorithm Benchmark Spec
#
# Verifies O(T + M + Z) time complexity where:
#   T = text length
#   M = total pattern length
#   Z = number of matches

# Helper to generate random strings
private def random_string(length : Int32) : String
  charset = "abcdefghij"
  String.build(length) { |s| length.times { s << charset[rand(charset.size)] } }
end

# Helper to generate unique patterns
private def generate_patterns(count : Int32, length : Int32) : Array(String)
  patterns = Set(String).new
  while patterns.size < count
    patterns << random_string(length)
  end
  patterns.to_a
end

# Benchmark helper - returns time in milliseconds
private def measure_search(patterns : Array(String), text : String) : Float64
  matcher = AhoCorasick.new(patterns)
  start = Time.instant
  matcher.match(text) { }
  (Time.instant - start).total_milliseconds
end

describe "AhoCorasick Benchmark" do
  describe "time complexity" do
    it "scales linearly with text length (O(T))" do
      patterns = generate_patterns(100, 5)

      time_1k = measure_search(patterns, random_string(1000))
      time_10k = measure_search(patterns, random_string(10000))

      # 10x text should take roughly 10x time (allow 3x-30x for variance)
      ratio = time_10k / time_1k
      ratio.should be > 3.0
      ratio.should be < 30.0
    end

    it "scales sub-linearly with pattern count" do
      text = random_string(10000)

      time_10p = measure_search(generate_patterns(10, 5), text)
      time_100p = measure_search(generate_patterns(100, 5), text)

      # 10x patterns should NOT take 10x time (sub-linear for search)
      ratio = time_100p / time_10p
      ratio.should be < 5.0
    end
  end

  describe "benchmark table" do
    it "generates complexity table" do
      pattern_counts = [1, 4, 16, 64, 256]
      text_lengths = [100, 400, 1600, 6400, 25600]
      pattern_length = 5

      max_patterns = generate_patterns(pattern_counts.max, pattern_length)
      results = Hash(Tuple(Int32, Int32), Float64).new

      # Collect measurements
      text_lengths.each do |text_len|
        text = random_string(text_len)
        pattern_counts.each do |pat_count|
          patterns = max_patterns.first(pat_count)
          results[{text_len, pat_count}] = measure_search(patterns, text)
        end
      end

      # Print table
      puts "\n"
      puts "=" * 70
      puts "  AHO-CORASICK COMPLEXITY: O(T + M + Z)"
      puts "=" * 70
      puts

      # Header
      print "Text Length".ljust(12)
      pattern_counts.each { |p| print "| #{p.to_s.rjust(6)}P " }
      puts "|"
      puts "-" * 12 + ("|" + "-" * 9) * pattern_counts.size + "|"

      # Data rows
      text_lengths.each do |text_len|
        print "#{text_len.to_s.rjust(10)}  "
        pattern_counts.each do |pat_count|
          time = results[{text_len, pat_count}]
          time_str = if time < 0.01
                       "#{(time * 1000).round(1)}µs"
                     elsif time < 1
                       "#{time.round(2)}ms"
                     else
                       "#{time.round(1)}ms"
                     end
          print "| #{time_str.rjust(7)} "
        end
        puts "|"
      end

      puts
      puts "Key: Doubling text length ≈ doubles time (linear)"
      puts "     Doubling patterns ≈ small constant increase"
      puts

      # Verify linear scaling in text length
      base = results[{100, 1}]
      large = results[{25600, 1}]
      (large / base).should be > 50  # 256x text should be >50x time
    end
  end
end
