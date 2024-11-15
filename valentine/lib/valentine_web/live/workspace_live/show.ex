defmodule ValentineWeb.WorkspaceLive.Show do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:workspace, Composer.get_workspace!(id))
     |> assign(:workspace_id, id)}
  end

  defp page_title(:show), do: "Show Workspace"
  defp page_title(:edit), do: "Edit Workspace"
end
