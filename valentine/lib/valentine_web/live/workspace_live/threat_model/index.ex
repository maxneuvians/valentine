defmodule ValentineWeb.WorkspaceLive.ThreatModel.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)

    {:ok,
     socket
     |> assign(:workspace, workspace)
     |> assign(:assumptions, workspace.assumptions)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Threat model")
  end

  defp get_assets(threats) do
    threats
    |> Enum.filter(&(&1.impacted_assets != [] && &1.impacted_assets != nil))
    |> Enum.reduce(%{}, fn t, acc ->
      Enum.reduce(t.impacted_assets, acc, fn asset, a ->
        Map.update(a, asset, [t.numeric_id], &(&1 ++ [t.numeric_id]))
      end)
    end)
    |> Enum.with_index()
  end

  defp get_workspace(id) do
    Composer.get_workspace!(id, [
      :application_information,
      :architecture,
      :data_flow_diagram,
      mitigations: [:assumptions, :threats],
      threats: [:assumptions, :mitigations],
      assumptions: [:threats, :mitigations]
    ])
  end

  defp optional_content(nil), do: "<i>Not set</i>"
  defp optional_content(model), do: model.content

  defp stride_to_letter(data) do
    data
    |> Enum.map(&Atom.to_string/1)
    |> Enum.map(&String.upcase/1)
    |> Enum.map(&String.first/1)
    |> Enum.join()
  end
end
