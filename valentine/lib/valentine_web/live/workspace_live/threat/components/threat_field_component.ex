defmodule ValentineWeb.WorkspaceLive.Threat.Components.ThreatFieldComponent do
  use ValentineWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      class="inline-block w-auto border border-gray-300 px-2 py-1 min-h-[38px] focus:outline-none focus:ring-2 focus:ring-primary-500"
      phx-focus="show_context"
      phx-value-field={@field}
      phx-value-type={@type}
      tabindex="0"
    >
      <%= if @value == "" || is_nil(@value), do: @placeholder, else: @value %>
    </div>
    """
  end
end
