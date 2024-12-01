defmodule ValentineWeb.WorkspaceLive.Components.IconComponent do
  use Phoenix.Component

  def icons(assigns) do
    %{
      "add-bounday-16" => ~H"""
      <svg
        class={@class}
        {@rest}
        xmlns="http://www.w3.org/2000/svg"
        width="16"
        height="16"
        viewBox="0 0 16 16"
      >
        <!-- Dashed Rectangle -->
        <rect
          x="10"
          y="10"
          width="80"
          height="80"
          fill="none"
          stroke="#000000"
          stroke-width="2"
          stroke-dasharray="5,5"
        />
        <!-- Plus Symbol -->
        <g transform="translate(65,25)">
          <!-- Horizontal line -->
          <line x1="-8" y1="0" x2="8" y2="0" stroke="#000000" stroke-width="2" />
          <!-- Vertical line -->
          <line x1="0" y1="-8" x2="0" y2="8" stroke="#000000" stroke-width="2" />
        </g>
      </svg>
      """
    }
  end
end
