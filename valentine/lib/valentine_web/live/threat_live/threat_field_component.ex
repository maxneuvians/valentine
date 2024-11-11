defmodule ValentineWeb.ThreatLive.ThreatFieldComponent do
  use ValentineWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      class="inline-block w-auto border border-gray-300 px-2 py-1 min-h-[38px] focus:outline-none focus:ring-2 focus:ring-primary-500"
      phx-focus="show_context"
      phx-value-field={@field}
      tabindex="0"
    >
      <%= with value <- Ecto.Changeset.get_change(@changeset, @field) || Ecto.Changeset.get_field(@changeset, @field) do
        if value == "" || is_nil(value), do: @placeholder, else: value
      end %>
    </div>
    """
  end
end
