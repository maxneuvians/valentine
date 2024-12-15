defmodule ValentineWeb.WorkspaceLive.Controls.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)

    {:ok,
     socket
     |> assign(:controls, Composer.list_controls())
     |> assign(:workspace, workspace)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "NIST Controls")
  end

  defp text_to_html(text) do
    text
    |> String.replace(~r/\n/, "<br>")
    |> String.replace(~r/\s/, "&nbsp;")
    |> String.replace(~r/\t/, "&nbsp;&nbsp;&nbsp;&nbsp;")
    |> Phoenix.HTML.raw()
  end

  defp get_workspace(id) do
    Composer.get_workspace!(id)
  end
end
