module BenchmarkHelper
  def benchmark
    Benchmark.realtime(&Proc.new)
  end
end
