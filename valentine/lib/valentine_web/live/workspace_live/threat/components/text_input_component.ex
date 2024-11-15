defmodule ValentineWeb.WorkspaceLive.Threat.Components.TextInputComponent do
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
          phx-window-keyup="update_field"
          value={@current_value}
        >
          <:trailing_action is_visible_with_value>
            <.button
              is_close_button
              aria-label="Clear"
              onclick={"document.querySelector('[name=threat-#{@active_field}]').value=''"}
            >
              <.octicon name="x-16" />
            </.button>
          </:trailing_action>
        </.text_input>

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
end
