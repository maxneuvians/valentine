defmodule ValentineWeb.WorkspaceLive.Components.Charts.BarChartComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.Charts.BarChartComponent

  defp setup_component(_) do
    assigns = %{
      __changed__: %{},
      data: %{},
      id: "bar-chart-component"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  describe "render/1" do
    setup [:setup_component]

    test "renders the component properly", %{assigns: assigns} do
      html = render_component(BarChartComponent, assigns)

      assert html =~ "bar-chart-component"
      assert html =~ "phx-hook=\"Chart\""
      assert html =~ "data-options="
    end
  end
end
