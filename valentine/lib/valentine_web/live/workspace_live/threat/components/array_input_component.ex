defmodule ValentineWeb.WorkspaceLive.Threat.Components.ArrayInputComponent do
  use ValentineWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-6">
      <div class="col-span-2">
        <div class="border rounded-lg p-6 bg-white">
          <h2 class="text-xl font-semibold mb-2"><%= @context.title %></h2>
          <p class="text-gray-600 mb-4"><%= @context.description %></p>
          <div class="space-y-2">
            <.input
              type="text"
              class="flex-1 rounded-lg border-gray-300"
              name={"threat[#{@active_field}]"}
              id={"#{@id}-#{@active_field}"}
              phx-window-keyup="set_tag"
              phx-target={@myself}
              value=""
            />
            <.button
              phx-click="add_tag"
              phx-target={@myself}
              class="px-4 py-2 bg-blue-500 text-white rounded-lg"
            >
              Add
            </.button>
          </div>
          <div class="flex gap-2 flex-wrap">
            <%= for tag <- @current_value do %>
              <div class="flex items-center gap-1 bg-gray-100 px-2 py-1 rounded">
                <span><%= tag %></span>
                <button
                  type="button"
                  phx-click="remove_tag"
                  phx-value-tag={tag}
                  phx-target={@myself}
                  class="text-gray-500 hover:text-gray-700"
                >
                  ×
                </button>
              </div>
            <% end %>
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
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add_tag", _params, %{assigns: %{tag: tag}} = socket)
      when byte_size(tag) > 0 do
    current_tags = socket.assigns.current_value || []

    if tag not in current_tags do
      updated_tags = current_tags ++ [tag]
      send(self(), {"update_field", %{"value" => updated_tags}})
      {:noreply, assign(socket, :current_value, updated_tags)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("add_tag", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("remove_tag", %{"tag" => tag}, socket) do
    updated_tags = List.delete(socket.assigns.current_value, tag)
    send(self(), {"update_field", %{"value" => updated_tags}})
    {:noreply, assign(socket, :current_value, updated_tags)}
  end

  @impl true
  def handle_event("set_tag", %{"value" => value} = _params, socket) do
    {:noreply, assign(socket, :tag, value)}
  end
end
