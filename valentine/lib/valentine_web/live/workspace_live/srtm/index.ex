defmodule ValentineWeb.WorkspaceLive.SRTM.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @nist_id_regex ~r/^[A-Za-z]{2}-\d+(\.\d+)?$/

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)
    controls = filter_controls(%{})

    assumed_controls = get_tagged_controls(workspace.assumptions)
    mitigated_controls = get_tagged_controls(workspace.mitigations)
    mapped_controls = allocated_controls(controls, assumed_controls, mitigated_controls)

    {:ok,
     socket
     |> assign(:controls, mapped_controls)
     |> assign(:filters, %{})
     |> assign(:workspace, workspace)}
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
end
