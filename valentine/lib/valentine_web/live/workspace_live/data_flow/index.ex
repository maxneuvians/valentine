defmodule ValentineWeb.WorkspaceLive.DataFlow.Index do
  use ValentineWeb, :live_view
  use PrimerLive
  require Logger

  alias Valentine.Composer
  alias Phoenix.PubSub

  alias Valentine.Composer.DataFlowDiagram

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = Composer.get_workspace!(workspace_id)

    # Subscribe to workspace-specific updates
    if connected?(socket) do
      PubSub.subscribe(Valentine.PubSub, "workspace_dataflow:#{workspace.id}")
    end

    dfd =
      DataFlowDiagram.get(workspace_id)

    {:ok,
     socket
     |> assign(:dfd, dfd)
     |> assign(:selected_elements, %{"nodes" => %{}, "edges" => %{}})
     |> assign(:touched, true)
     |> assign(:workspace_id, workspace_id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Data flow diagram")
  end

  # Intercept select and unselect events
  @impl true
  def handle_event("select", %{"id" => id, "label" => label, "group" => group}, socket) do
    selected_elements = put_in(socket.assigns.selected_elements, [group, id], label)

    {:noreply,
     socket
     |> assign(:selected_elements, selected_elements)}
  end

  @impl true
  def handle_event("unselect", %{"id" => id, "group" => group}, socket) do
    {_, selected_elements} = pop_in(socket.assigns.selected_elements, [group, id])

    {:noreply,
     socket
     |> assign(:selected_elements, selected_elements)}
  end

  # Local event from HTML or JS
  @impl true
  def handle_event(event, params, socket) do
    Logger.info("Local event: #{inspect(event)}, payload: #{inspect(params)}")

    params = Map.put(params, "selected_elements", socket.assigns.selected_elements)

    case Kernel.apply(Valentine.Composer.DataFlowDiagram, String.to_existing_atom(event), [
           socket.assigns.workspace_id,
           params
         ]) do
      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}

      payload ->
        broadcast("workspace_dataflow:#{socket.assigns.workspace_id}", %{
          event: event,
          payload: payload
        })

        if Map.has_key?(params, "localJs") do
          {:noreply, socket}
        else
          {:noreply,
           socket
           |> push_event("updateGraph", %{
             event: event,
             payload: payload
           })
           |> assign(:touched, !socket.assigns.touched)}
        end
    end
  end

  # Remote event from PubSub
  @impl true
  def handle_info(%{event: event, payload: payload}, socket) do
    Logger.info("Remote event: #{inspect(event)}, Payload: #{inspect(payload)}")

    {:noreply,
     socket
     |> push_event("updateGraph", %{event: event, payload: payload})}
  end

  defp broadcast(topic, payload) do
    PubSub.broadcast_from!(Valentine.PubSub, self(), topic, payload)
  end
end
