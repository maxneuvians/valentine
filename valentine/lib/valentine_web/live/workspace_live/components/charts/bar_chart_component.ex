defmodule ValentineWeb.WorkspaceLive.Components.Charts.BarChartComponent do
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
      series: [
        %{
          data: Map.values(assigns.data)
        }
      ],
      plotOptions: %{
        bar: %{
          horizontal: true
        }
      },
      chart: %{
        type: "bar"
      },
      xaxis: %{
        categories: Map.keys(assigns.data)
      }
    }
  end
end
