defmodule ValentineWeb.WorkspaceLive.SRTM.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)

    {:ok,
     socket
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
end
