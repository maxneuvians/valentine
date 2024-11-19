defmodule ValentineWeb.WorkspaceLive.Assumption.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer
  alias Valentine.Composer.Assumption

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = Composer.get_workspace!(workspace_id)

    ValentineWeb.Endpoint.subscribe("workspace_" <> workspace.id)

    {:ok,
     socket
     |> assign(:workspace_id, workspace_id)
     |> assign(:assumptions, Composer.list_assumptions_by_workspace(workspace_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Assumption")
    |> assign(:assumption, Composer.get_assumption!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(
      :page_title,
      "New Assumption"
    )
    |> assign(:assumption, %Assumption{workspace_id: socket.assigns.workspace_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Assumption")
  end

  @impl true
  def handle_info(
        {ValentineWeb.WorkspaceLive.Assumption.Components.FormComponent, {:saved, _assumption}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:assumptions, Composer.list_assumptions_by_workspace(socket.assigns.workspace_id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case Composer.get_assumption!(id) do
      nil ->
        {:noreply, socket |> put_flash(:error, "Assumption not found")}

      assumption ->
        case Composer.delete_assumption(assumption) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Assumption deleted successfully")
             |> assign(
               :assumptions,
               Composer.list_assumptions_by_workspace(socket.assigns.workspace_id)
             )}

          {:error, _} ->
            {:noreply, socket |> put_flash(:error, "Failed to delete assumption")}
        end
    end
  end
end
