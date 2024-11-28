defmodule ValentineWeb.WorkspaceLive.ApplicationInformation.Index do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer
  alias Phoenix.PubSub

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = Composer.get_workspace!(workspace_id)

    # Subscribe to workspace-specific updates
    if connected?(socket) do
      PubSub.subscribe(Valentine.PubSub, "workspace_application_information:#{workspace.id}")
    end

    ops_cache = Composer.ApplicationInformation.get_cache(workspace.id)

    socket =
      ops_cache
      |> Enum.reduce(socket, fn ops, socket ->
        socket
        |> push_event("updateQuill", %{event: "text_change", payload: %{ops: ops}})
      end)

    {:ok,
     socket
     |> assign(:content, "")
     |> assign(:workspace_id, workspace_id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Application information")
  end

  @impl true
  def handle_info({:quill_change, delta}, socket) do
    Composer.ApplicationInformation.push_cache(socket.assigns.workspace_id, [delta["ops"]])

    broadcast("workspace_application_information:#{socket.assigns.workspace_id}", %{
      event: :quill_change,
      payload: delta
    })

    {:noreply, socket}
  end

  # Remote change
  @impl true
  def handle_info(%{event: :quill_change, payload: payload}, socket) do
    {:noreply,
     socket
     |> push_event("updateQuill", %{event: "text_change", payload: payload})}
  end

  defp broadcast(topic, payload) do
    PubSub.broadcast_from!(Valentine.PubSub, self(), topic, payload)
  end
end
