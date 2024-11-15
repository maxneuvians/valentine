defmodule ValentineWeb.WorkspaceLive.Threat.Components.ArrayInputComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.styled_html>
        <h3><%= @context.title %></h3>
        <p><%= @context.description %></p>
        <.text_input
          id={"#{@id}-#{@active_field}"}
          name={"threat-#{@active_field}"}
          phx-window-keyup="set_tag"
          phx-target={@myself}
          value=""
        >
          <:group_button>
            <.button phx-click="add_tag" phx-target={@myself}>Add</.button>
          </:group_button>
        </.text_input>
        <div class="mt-2">
          <%= for tag <- @current_value do %>
            <.button phx-click="remove_tag" phx-value-tag={tag} phx-target={@myself}>
              <span><%= tag %></span>
              <.octicon name="x-16" />
            </.button>
          <% end %>
        </div>
        <%= if @context.examples && length(@context.examples) > 0 do %>
          <h4>Examples:</h4>
          <ul>
            <%= for example <- @context.examples do %>
              <li><%= example %></li>
            <% end %>
          </ul>
        <% end %>
      </.styled_html>
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
