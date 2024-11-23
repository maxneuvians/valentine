defmodule ValentineWeb.WorkspaceLive.Components.FlashComponent do
  use Phoenix.Component
  use PrimerLive

  # Add JS hook for auto-hiding
  attr :id, :string, default: "flash-group"
  attr :auto_hide, :string, default: "true"
  attr :flash, :map, default: %{}
  attr :hide_after, :integer, default: 5000

  def flash_group(assigns) do
    ~H"""
    <div id={@id} phx-hook="AutoHideFlash" data-auto-hide={@auto_hide} data-hide-after={@hide_after}>
      <.alert_messages>
        <%= for {kind, message} <- @flash do %>
          <.alert state={kind} class="mt-2" id={"flash-#{kind}"}>
            <%= message %>
            <.button class="flash-close" phx-click="lv:clear-flash">
              <.octicon name="x-16" />
            </.button>
          </.alert>
        <% end %>
      </.alert_messages>
    </div>
    """
  end
end
