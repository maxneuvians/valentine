defmodule ValentineWeb.WorkspaceLive.Mitigation.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer
  alias Valentine.Composer.Mitigation

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)

    ValentineWeb.Endpoint.subscribe("workspace_" <> workspace.id)

    {:ok,
     socket
     |> assign(:workspace_id, workspace_id)
     |> assign(:mitigations, workspace.mitigations)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mitigation")
    |> assign(:mitigation, Composer.get_mitigation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(
      :page_title,
      "New Mitigation"
    )
    |> assign(:mitigation, %Mitigation{workspace_id: socket.assigns.workspace_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Mitigations")
  end

  @impl true
  def handle_info(
        {ValentineWeb.WorkspaceLive.Mitigation.Components.FormComponent, {:saved, _mitigation}},
        socket
      ) do
    workspace = get_workspace(socket.assigns.workspace_id)

    {:noreply,
     socket
     |> assign(:mitigations, workspace.mitigations)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case Composer.get_mitigation!(id) do
      nil ->
        {:noreply, socket |> put_flash(:error, "Mitigation not found")}

      mitigation ->
        case Composer.delete_mitigation(mitigation) do
          {:ok, _} ->
            workspace = get_workspace(socket.assigns.workspace_id)

            {:noreply,
             socket
             |> put_flash(:info, "Mitigation deleted successfully")
             |> assign(
               :mitigations,
               workspace.mitigations
             )}

          {:error, _} ->
            {:noreply, socket |> put_flash(:error, "Failed to delete mitigation")}
        end
    end
  end

  defp get_workspace(id) do
    Composer.get_workspace!(id, [:mitigations])
  end
end
