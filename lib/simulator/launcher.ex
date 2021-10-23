defmodule Simulator.Launcher do
  @moduledoc """
  Starts the simulation and writes result metrics to files.
  """

  use Simulator.BaseConstants

  import Nx.Defn

  alias Simulator.Phase.{RemoteConsequences, RemotePlans, RemoteSignal, StartIteration}
  alias Simulator.Printer

  def start(grid, objects_state) do
    create_plan = &@module_prefix.PlanCreator.create_plan/6
    is_update_valid? = &@module_prefix.PlanResolver.is_update_valid?/2
    apply_action = &@module_prefix.PlanResolver.apply_action/3
    apply_consequence = &@module_prefix.PlanResolver.apply_consequence/3
    generate_signal = &@module_prefix.Cell.generate_signal/1
    signal_factor = &@module_prefix.Cell.signal_factor/1

    simulate(
      grid,
      objects_state,
      create_plan,
      is_update_valid?,
      apply_action,
      apply_consequence,
      generate_signal,
      signal_factor
    )
    |> Printer.write_all_to_files()
  end

  defnp simulate(
          grid,
          objects_state,
          create_plan,
          is_update_valid?,
          apply_action,
          apply_consequence,
          generate_signal,
          signal_factor
        ) do
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
