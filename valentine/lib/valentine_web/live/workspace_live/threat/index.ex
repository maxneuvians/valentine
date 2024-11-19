defmodule ValentineWeb.WorkspaceLive.Threat.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = Composer.get_workspace!(workspace_id)
    ValentineWeb.Endpoint.subscribe("workspace_" <> workspace.id)

    {:ok,
     socket
     |> assign(:workspace_id, workspace_id)
     |> assign(:filters, %{})
     |> assign(:threats, Composer.list_threats_by_workspace(workspace.id, %{}))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"workspace_id" => workspace_id} = _params) do
    socket
    |> assign(:page_title, "Listing threats")
    |> assign(:workspace_id, workspace_id)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case Composer.get_threat!(id) do
      nil ->
        {:noreply, socket |> put_flash(:error, "Threat not found")}

      threat ->
        case Composer.delete_threat(threat) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Threat deleted successfully")
             |> assign(
               :threats,
               Composer.list_threats_by_workspace(
                 socket.assigns.workspace_id,
                 socket.assigns.filters
               )
             )}

          {:error, _} ->
            {:noreply, socket |> put_flash(:error, "Failed to delete threat")}
        end
    end
  end

  @impl true
  def handle_event("clear_filters", _params, socket) do
    {:noreply,
     socket
     |> assign(:filters, %{})
     |> assign(
       :threats,
       Composer.list_threats_by_workspace(socket.assigns.workspace_id, %{})
     )}
  end

  @impl true
  def handle_info({:update_filter, filters}, socket) do
    {
      :noreply,
      socket
      |> assign(:filters, filters)
      |> assign(
        :threats,
        Composer.list_threats_by_workspace(socket.assigns.workspace_id, filters)
      )
    }
  end

  @impl true
  def handle_info(%{topic: "workspace_" <> workspace_id}, socket) do
    {:noreply,
     assign(
       socket,
       :threats,
       Composer.list_threats_by_workspace(workspace_id, socket.assigns.filters)
     )}
  end
end
