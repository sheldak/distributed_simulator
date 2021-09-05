defmodule Simulator.Helpers do
  import Nx.Defn

  @dir_stay 0
  @dir_top 1
  @dir_top_right 2
  @dir_right 3
  @dir_bottom_right 4
  @dir_bottom 5
  @dir_bottom_left 6
  @dir_left 7
  @dir_top_left 8

  defn shift({x, y}, direction) do
    cond do
      Nx.equal(direction, @dir_stay) -> {x, y}
      Nx.equal(direction, @dir_top) -> {x - 1, y}
      Nx.equal(direction, @dir_top_right) -> {x - 1, y + 1}
      Nx.equal(direction, @dir_right) -> {x, y + 1}
      Nx.equal(direction, @dir_bottom_right) -> {x + 1, y + 1}
      Nx.equal(direction, @dir_bottom) -> {x + 1, y}
      Nx.equal(direction, @dir_bottom_left) -> {x + 1, y - 1}
      Nx.equal(direction, @dir_left) -> {x, y - 1}
      Nx.equal(direction, @dir_top_left) -> {x - 1, y - 1}
      # todo why? shouldn't throw? // I think we cannot throw from defn. Any suggestions what to do with that?
      true -> {0, 0}
    end
  end

  @doc """
  Checks whether the mock can move to position {x, y}.
  """
  defn can_move({x, y}, grid) do
    [is_valid({x, y}, grid), Nx.equal(grid[x][y][0], 0)]
    |> Nx.stack()
    |> Nx.all?()
  end

  @doc """
  Checks if position {x, y} is inside the grid.
  """
  defn is_valid({x, y}, grid) do
    {x_size, y_size, _} = Nx.shape(grid)

    [
      Nx.greater_equal(x, 0),
      Nx.less(x, x_size),
      Nx.greater_equal(y, 0),
      Nx.less(y, y_size)
    ]
    |> Nx.stack()
    |> Nx.all?()
  end
end
