defmodule ValentineWeb.WorkspaceLive.Components.QuillComponent do
  use ValentineWeb, :live_component

  use PrimerLive

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="Quill" id="quill-holder">
      <div id="quill-editor">{Phoenix.HTML.raw(@content)}</div>
    </div>
    """
  end

  @impl true
  def handle_event("quill-change", %{"delta" => delta}, socket) do
    send(self(), {:quill_change, delta})
    {:noreply, socket}
  end

  @impl true
  def handle_event("quill-save", %{"content" => content}, socket) do
    send(self(), {:quill_save, content})
    {:noreply, socket}
  end
end
