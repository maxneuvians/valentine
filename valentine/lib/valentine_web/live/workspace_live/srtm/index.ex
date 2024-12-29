defmodule ValentineWeb.WorkspaceLive.SRTM.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @nist_id_regex ~r/^[A-Za-z]{2}-\d+(\.\d+)?$/

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)
    controls = filter_controls(%{})

    {:ok,
     socket
     |> assign(:controls, map_controls(controls, workspace))
     |> assign(:filters, %{})
     |> assign(:workspace, workspace)}
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    workspace = socket.assigns.workspace
    controls = filter_controls(%{})

    {
      :noreply,
      socket
      |> assign(:filters, %{})
      |> assign(
        :controls,
        map_controls(controls, workspace)
      )
    }
  end

  @impl true
  def handle_info({:update_filter, filters}, socket) do
    workspace = socket.assigns.workspace
    controls = filter_controls(filters)

    {
      :noreply,
      socket
      |> assign(:filters, filters)
      |> assign(
        :controls,
        map_controls(controls, workspace)
      )
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Security Requirements Traceability Matrix")
  end

  defp allocated_controls(controls, assumed, mitigated) do
    assumed_ids = Map.keys(assumed)
    mitigated_ids = Map.keys(mitigated)

    initial_acc = %{
      not_allocated: %{},
      out_of_scope: %{},
      in_scope: %{}
    }

    Enum.reduce(controls, initial_acc, fn control, acc ->
      cond do
        control.nist_id in assumed_ids ->
          put_in(
            acc,
            [:out_of_scope, control.nist_id],
            [{control, assumed[control.nist_id]}]
          )

        control.nist_id in mitigated_ids ->
          put_in(
            acc,
            [:in_scope, control.nist_id],
            [{control, mitigated[control.nist_id]}]
          )

        true ->
          put_in(
            acc,
            [:not_allocated, control.nist_id],
            [control]
          )
      end
    end)
  end

  defp filter_controls(filters) when map_size(filters) == 0,
    do: Composer.list_controls()

  defp filter_controls(filters) do
    filters = Map.values(filters) |> List.flatten()
    Composer.list_controls_by_tags(filters)
  end

  defp get_tagged_controls(collection) do
    collection
    |> Enum.reduce(%{}, fn item, acc ->
      item.tags
      |> Enum.filter(&Regex.match?(@nist_id_regex, &1))
      |> Enum.reduce(acc, fn tag, acc ->
        Map.update(acc, tag, [item], &(&1 ++ [item]))
      end)
    end)
  end

  defp get_workspace(id) do
    Composer.get_workspace!(id,
      mitigations: [:assumptions, :threats],
      threats: [:assumptions, :mitigations],
      assumptions: [:threats, :mitigations]
    )
  end

  defp map_controls(controls, workspace) do
    assumed_controls = get_tagged_controls(workspace.assumptions)
    mitigated_controls = get_tagged_controls(workspace.mitigations)
    allocated_controls(controls, assumed_controls, mitigated_controls)
  end

  defp calculate_percentage(controls, scope) do
    total_controls =
      controls
      |> Map.values()
      |> Enum.map(&map_size/1)
      |> Enum.sum()

    case total_controls do
      0 ->
        0

      _ ->
        scope_count = map_size(controls[scope])
        round(scope_count / total_controls * 100)
    end
  end

  defp scope_progress_class(scope) do
    case scope do
      :not_allocated -> "error"
      :out_of_scope -> "info"
      :in_scope -> "success"
    end
  end
end
