defmodule ValentineWeb.WorkspaceLive.Threat.Components.ContextHelpComponent do
  use ValentineWeb, :live_component

  @impl true
  def update(assigns, socket) do
    current_value =
      if assigns.active_field do
        get_field_value(assigns.form, assigns.active_field, assigns.context.field_type)
      else
        get_default_value(assigns.context.field_type)
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_value, current_value)}
  end

  defp get_default_value("array"), do: []
  defp get_default_value(_), do: ""

  defp get_field_value(form, field, field_type) do
    case form.params[Atom.to_string(field)] || Ecto.Changeset.get_field(form.source, field) do
      nil -> get_default_value(field_type)
      value -> value
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-6">
      <div class="col-span-2">
        <div class="border rounded-lg p-6 bg-white">
          <h2 class="text-xl font-semibold mb-2"><%= @context.title %></h2>
          <p class="text-gray-600 mb-4"><%= @context.description %></p>

          <div class="space-y-4">
            <%= case @context.field_type do %>
              <% "array" -> %>
                <div class="space-y-2">
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
                  <.input
                    type="text"
                    placeholder={@context.placeholder}
                    class="flex-1 rounded-lg border-gray-300"
                    name={"threat[#{@active_field}]"}
                    id={"#{@id}-#{@active_field}"}
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
              <% _ -> %>
                <.input
                  type="textarea"
                  field={@form[@active_field]}
                  placeholder={@context.placeholder}
                  rows="4"
                  class="w-full"
                  name={"threat[#{@active_field}]"}
                  id={"#{@id}-#{@active_field}"}
                  phx-change="update_field"
                  phx-target={@myself}
                  value={@current_value}
                />
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
  def handle_event("update_field", %{"threat" => params}, socket) do
    value = params[Atom.to_string(socket.assigns.active_field)]
    send(self(), {:update_field, value})
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_tag", %{"tag" => tag}, socket) when byte_size(tag) > 0 do
    current_tags = socket.assigns.current_value || []

    if tag not in current_tags do
      updated_tags = current_tags ++ [tag]
      send(self(), {:update_field, updated_tags})
      {:noreply, assign(socket, :current_value, updated_tags)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("add_tag", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("remove_tag", %{"tag" => tag}, socket) do
    updated_tags = List.delete(socket.assigns.current_value, tag)
    send(self(), {:update_field, updated_tags})
    {:noreply, assign(socket, :current_value, updated_tags)}
  end

  defp field_completed?(changeset, field) do
    value =
      Ecto.Changeset.get_change(changeset, field) ||
        Ecto.Changeset.get_field(changeset, field)

    case value do
      nil -> false
      [] -> false
      "" -> false
      _ when is_list(value) -> length(value) > 0
      _ -> String.trim(to_string(value)) != ""
    end
  end
end
