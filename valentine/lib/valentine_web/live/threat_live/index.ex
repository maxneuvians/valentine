defmodule ValentineWeb.ThreatLive.Index do
  use ValentineWeb, :live_view

  alias Valentine.Composer
  alias Valentine.Composer.Threat

  @topic "threats"

  @impl true
  def mount(_params, _session, socket) do
    ValentineWeb.Endpoint.subscribe(@topic)
    {:ok, stream(socket, :threats, Composer.list_threats())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing threats")
    |> assign(:threat, nil)
  end

  @impl true
  def handle_info(%{topic: @topic, payload: state}, socket) do
    {:noreply, stream(socket, :threats, Composer.list_threats())}
  end

end
