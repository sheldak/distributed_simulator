defmodule Simulator.Launcher do
  @moduledoc """
  Starts the simulation and writes result metrics to files.
  """

  use Simulator.BaseConstants

  import Nx.Defn

  alias Simulator.Phase.{RemoteConsequences, RemotePlans, RemoteSignal, StartIteration}
  alias Simulator.{Functions, Printer}

  def start(grid) do
    functions = {
      &@module_prefix.PlanCreator.create_plan/6,
      &@module_prefix.PlanResolver.is_update_valid?/2,
      &@module_prefix.PlanResolver.apply_action/3,
      &@module_prefix.PlanResolver.apply_consequence/3,
      &@module_prefix.Cell.generate_signal/1,
      &@module_prefix.Cell.signal_factor/1
    }

    grid
    |> simulate(objects_state, functions)
    |> Printer.write_all_to_files()
  end

  defnp simulate(grid, objects_state, functions) do
    {create_plan, is_update_valid?, apply_action, apply_consequence, generate_signal, signal_factor} = functions
    {x_size, y_size, z_size} = Nx.shape(grid)

    {_iteration, _grid, _objects_state, visualization} =
      while {iteration = 0, grid, objects_state, visualization = Nx.broadcast(0, {@max_iterations, x_size, y_size, z_size})},
            Nx.less(iteration, @max_iterations) do
        plans = StartIteration.create_plans(iteration, grid, objects_state, create_plan)

        {grid, accepted_plans, objects_state} =
          RemotePlans.process_plans(grid, plans, objects_state, is_update_valid?, apply_action)

        {grid, objects_state} = RemoteConsequences.apply_consequences(grid, objects_state, plans, accepted_plans, apply_consequence)
        signal_update = RemoteConsequences.calculate_signal_updates(grid, generate_signal)

        grid = RemoteSignal.apply_signal_update(grid, signal_update, signal_factor)

        visualization = Nx.put_slice(visualization, [iteration, 0, 0, 0], Nx.broadcast(grid, {1, x_size, y_size, z_size}))
        {iteration + 1, grid, objects_state, visualization}
      end

    visualization
  end
end
