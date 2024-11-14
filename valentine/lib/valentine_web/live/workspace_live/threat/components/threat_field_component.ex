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
      <%= render_value(@value, @placeholder) %>
    </div>
    """
  end

  def render_value(nil, placeholder), do: placeholder
  def render_value("", placeholder), do: placeholder
  def render_value([], placeholder), do: placeholder
  def render_value(value, _) when is_binary(value), do: value

  def render_value(value, _) when is_list(value),
    do: ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpers.join_list(value)
end
