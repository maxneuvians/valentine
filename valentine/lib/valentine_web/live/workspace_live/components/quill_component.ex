defmodule ValentineWeb.WorkspaceLive.Components.QuillComponent do
  use ValentineWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="Quill" id="quill-holder">
      <div id="quill-editor"><%= @content %></div>
    </div>
    """
  end

  @impl true
  def handle_event("quill-change", %{"delta" => delta}, socket) do
    # Send the delta to the parent live view for broadcast and processing
    send(self(), {:quill_change, delta})
    {:noreply, socket}
  end
end
