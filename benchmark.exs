defmodule Benchmark do
  alias API

  def run do
    API.fetch_all_courses
  end
end

Benchmark.run
