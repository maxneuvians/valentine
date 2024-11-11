defmodule ValentineWeb.WorkspaceLive.Index do
  use ValentineWeb, :live_view

  alias Valentine.Composer
  alias Valentine.Composer.Workspace

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :workspaces, Composer.list_workspaces())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Workspace")
    |> assign(:workspace, Composer.get_workspace!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Workspace")
    |> assign(:workspace, %Workspace{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Workspaces")
    |> assign(:workspace, nil)
  end

  @impl true
  def handle_info({ValentineWeb.WorkspaceLive.FormComponent, {:saved, workspace}}, socket) do
    {:noreply, stream_insert(socket, :workspaces, workspace)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    workspace = Composer.get_workspace!(id)
    {:ok, _} = Composer.delete_workspace(workspace)

    {:noreply, stream_delete(socket, :workspaces, workspace)}
  end
end
