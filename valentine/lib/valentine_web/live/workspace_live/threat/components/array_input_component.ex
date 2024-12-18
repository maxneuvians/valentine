defmodule ValentineWeb.WorkspaceLive.Threat.Components.ArrayInputComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  @impl true
  def render(assigns) do
    assigns =
      if assigns[:value] == nil do
        assign(assigns, :value, "")
      else
        assigns
      end

    ~H"""
    <div>
      <.styled_html>
        <h3>{@context.title}</h3>
        <p>{@context.description}</p>
        <.text_input
          id={"#{@id}-#{@active_field}"}
          name={"threat-#{@active_field}"}
          phx-keyup="set_tag"
          phx-target={@myself}
          value={@value}
        >
          <:group_button>
            <.button phx-click="add_tag" phx-target={@myself}>Add</.button>
          </:group_button>
        </.text_input>
        <div class="mt-2">
          <%= for tag <- @current_value do %>
            <.button phx-click="remove_tag" phx-value-tag={tag} phx-target={@myself}>
              <span>{tag}</span>
              <.octicon name="x-16" />
            </.button>
          <% end %>
        </div>
        <div class="clearfix">
          <div class="float-left col-6">
            <%= if @context.examples && length(@context.examples) > 0 do %>
              <h4>Generic examples:</h4>
              <ul>
                <%= for example <- @context.examples do %>
                  <li>
                    <.link phx-click="set_tag" phx-value-value={example} phx-target={@myself}>
                      {example}
                    </.link>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </div>
          <div class="float-left col-6">
            <%= if @dfd_examples && length(@dfd_examples) > 0 do %>
              <h4>From data flow diagram:</h4>
              <ul>
                <%= for example <- @dfd_examples do %>
                  <li>
                    <.link phx-click="set_tag" phx-value-value={example} phx-target={@myself}>
                      {example}
                    </.link>
                  </li>
                <% end %>
              </ul>
            <% end %>
          </div>
        </div>
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
      {:noreply, assign(socket, :current_value, updated_tags) |> assign(:value, "")}
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
    {:noreply, assign(socket, :tag, value) |> assign(:value, value)}
  end
end
