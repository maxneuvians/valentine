defmodule ValentineWeb.WorkspaceLive.Components.DrawerComponent do
  use ValentineWeb, :live_component

  def mount(socket) do
    {:ok, socket |> assign(open_drawer: false) |> assign(count: 0)}
  end

  def handle_event("toggle_drawer", _params, socket) do
    {:noreply, socket |> assign(open_drawer: !socket.assigns.open_drawer)}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-2 mt-4 mb-4">
      <div class="w-full border border-gray-300 rounded-lg">
        <button
          phx-click="toggle_drawer"
          phx-target={@myself}
          class="w-full px-4 py-3 flex items-center gap-2 text-left hover:bg-gray-50"
        >
          <svg
            class={"w-4 h-4 transition-transform #{if @open_drawer, do: "rotate-90"}"}
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
          <span class="font-medium"><%= @title %></span>
          <%= if @count > 0 do %>
            <span class="text-gray-500">(<%= @count %>)</span>
          <% end %>
        </button>

        <%= if @open_drawer do %>
          <div class="px-4 py-3 border-t">
            <%= render_slot(@content) %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
