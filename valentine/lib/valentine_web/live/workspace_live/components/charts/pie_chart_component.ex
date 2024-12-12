defmodule ValentineWeb.WorkspaceLive.Components.Charts.PieChartComponent do
  use ValentineWeb, :live_component

  def mount(socket) do
    {:ok,
     socket
     |> assign(:id, "chart-#{socket.id}")
     |> assign(:data, %{})}
  end

  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook="Chart" data-options={Jason.encode!(chart_options(assigns))}></div>
    """
  end

  defp chart_options(assigns) do
    %{
      series: Map.values(assigns.data),
      chart: %{
        type: "pie"
      },
      labels: Map.keys(assigns.data)
    }
  end
end
