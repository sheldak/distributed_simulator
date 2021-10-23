defmodule Simulator.Printer do
  @moduledoc """
  Prints and writes to files.
  """

  @doc """
  Writes all grids of the visualization to files.
  """
  def write_all_to_files(visualizations) do
    {iterations, _x_size, _y_size, _z_size} = Nx.shape(visualizations)

    Enum.each(
      1..iterations,
      fn iteration -> write_to_file(visualizations[iteration-1], "grid_#{iteration}") end
    )
  end

  @doc """
  Writes grid as tensor to file. Firstly, it is converted to string.

  Prints the string as well.
  """
  def write_to_file(grid, file_name) do
    grid_as_string = tensor_to_string(grid)
    # IO.inspect(grid_as_string)

    File.write!("lib/grid_iterations/#{file_name}.txt", grid_as_string)
  end

  @doc """
  Prints given `grid`.
  """
  def print(grid, phase \\ nil) do
    unless phase == nil, do: IO.inspect(phase)
    IO.puts(tensor_to_string(grid) <> "\n\n")
  end

  @doc """
  Prints only the objects from the given `grid`.
  """
  def print_objects(grid, phase \\ nil) do
    unless phase == nil, do: IO.inspect(phase)

    {x_size, _y_size, _z_size} = Nx.shape(grid)

    Nx.to_flat_list(grid)
    |> Enum.map(fn num -> to_string(num) end)
    |> Enum.chunk_every(9)
    |> Enum.map(fn [object | _rest] -> object end)
    |> Enum.chunk_every(x_size)
    |> Enum.map(fn line -> Enum.join(line, " ") end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  @doc """
  Prints the plans in a readable way.
  """
  def print_plans(plans) do
    {x_size, y_size, _} = Nx.shape(plans)

    Nx.to_flat_list(plans)
    |> Enum.map(fn num -> to_string(num) end)
    |> Enum.chunk_every(3 * x_size)
    |> Enum.map(fn line ->
      Enum.chunk_every(line, 3)
      |> Enum.map(fn plan -> Enum.join(plan, " ") end)
      |> Enum.join("\n")
    end)
    |> Enum.join("\n\n")
    |> IO.puts()
  end

  # Converts grid as tensor to (relatively) readable string.
  defp tensor_to_string(tensor) do
    {x_size, y_size, _} = Nx.shape(tensor)

    ans =
      [x_size, y_size]
      |> Enum.concat(Nx.to_flat_list(tensor))
      |> Enum.map(fn num -> to_string(num) end)
      |> Enum.join(" ")

    ans
    end
end
