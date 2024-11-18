defmodule ValentineWeb.WorkspaceLive.Components.FlashComponent do
  use Phoenix.Component
  use PrimerLive

  def flash_group(assigns) do
    ~H"""
    <.alert_messages>
      <%= for {kind, message} <- @flash do %>
        <.alert state={kind} class="mt-2">
          <%= message %>
          <.button class="flash-close" phx-click="lv:clear-flash">
            <.octicon name="x-16" />
          </.button>
        </.alert>
      <% end %>
    </.alert_messages>
    """
  end
end
