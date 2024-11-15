defmodule ValentineWeb.WorkspaceLive.Threat.Components.TextInputComponent do
  use ValentineWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-gray-300 rounded-lg p-6 bg-white">
      <h2 class="text-xl font-semibold mb-2"><%= @context.title %></h2>
      <p class="text-gray-600 mb-4"><%= @context.description %></p>

      <div class="space-y-4">
        <.input
          type="textarea"
          rows="4"
          class="w-full"
          id={"#{@id}-#{@active_field}"}
          name={"threat[#{@active_field}]"}
          phx-window-keyup="update_field"
          value={@current_value}
        />
      </div>

      <%= if @context.examples && length(@context.examples) > 0 do %>
        <div class="mt-4">
          <h3 class="font-medium mb-2">Examples:</h3>
          <ul class="list-disc pl-5 space-y-1">
            <%= for example <- @context.examples do %>
              <li class="text-gray-600"><%= example %></li>
            <% end %>
          </ul>
        </div>
      <% end %>
    </div>
    """
  end
end
