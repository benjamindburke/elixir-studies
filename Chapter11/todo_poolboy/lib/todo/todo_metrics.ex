defmodule Todo.Metrics do
  use Task

  def start_link(_), do: Task.start_link(&loop/0)

  defp loop do
    Process.sleep(:timer.seconds(10))
    IO.inspect(collect_metrics())
    loop()
  end

  defp collect_metrics do
    memory_B = :erlang.memory(:total)
    memory_KB = memory_B / 1024
    memory_MB = memory_KB / 1024
    memory_GB = memory_MB / 1024
    [
      memory_usage: memory_B,
      memory_usage_KB: "#{memory_KB} KB",
      memory_usage_KB: "#{memory_MB} MB",
      memory_usage_GB: "#{memory_GB} GB",
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
