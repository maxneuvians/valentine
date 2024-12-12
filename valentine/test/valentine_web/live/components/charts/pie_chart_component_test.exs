defmodule ValentineWeb.WorkspaceLive.Components.Charts.PieChartComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.Charts.PieChartComponent

  defp setup_component(_) do
    assigns = %{
      __changed__: %{},
      data: %{},
      id: "pie-chart-component"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  describe "render/1" do
    setup [:setup_component]

    test "renders the component properly", %{assigns: assigns} do
      html = render_component(PieChartComponent, assigns)

      assert html =~ "pie-chart-component"
      assert html =~ "phx-hook=\"Chart\""
      assert html =~ "data-options="
    end
  end
end
