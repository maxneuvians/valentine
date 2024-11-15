defmodule ValentineWeb.WorkspaceLive.Components.FlashComponent do
  use Phoenix.Component
  use PrimerLive

  alias Phoenix.LiveView.JS

  def flash_group(assigns) do
    ~H"""
    <.alert_messages>
      <%= for {kind, message} <- @flash do %>
        <.alert state={kind} class="mt-2">
          <%= message %>
          <.button
            class="flash-close"
            phx-click={
              JS.push("lv:clear-flash", value: %{key: kind})
              |> ValentineWeb.CoreComponents.hide("#flash-#{kind}")
            }
          >
            <.octicon name="x-16" />
          </.button>
        </.alert>
      <% end %>
    </.alert_messages>
    """
  end
end
