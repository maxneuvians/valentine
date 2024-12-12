defmodule ValentineWeb.WorkspaceLive.Show do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:workspace, Composer.get_workspace!(id, [:threats, :mitigations]))
     |> assign(:workspace_id, id)}
  end

  defp page_title(:show), do: "Show Workspace"

  defp data_by_field(data, field) do
    data
    |> Enum.group_by(&get_in(&1, [Access.key!(field)]))
    |> Enum.map(fn
      {nil, data} -> {"Not set", Enum.count(data)}
      {value, data} -> {Phoenix.Naming.humanize(value), Enum.count(data)}
    end)
    |> Map.new()
  end

  defp threat_stride_count(threats) do
    stride = %{
      spoofing: 0,
      tampering: 0,
      repudiation: 0,
      information_disclosure: 0,
      denial_of_service: 0,
      elevation_of_privilege: 0
    }

    threats
    |> Enum.reduce(stride, fn threat, acc ->
      Enum.reduce(threat.stride, acc, fn category, inner_acc ->
        Map.update(inner_acc, category, 1, &(&1 + 1))
      end)
    end)
    |> Enum.map(fn {category, count} -> {Phoenix.Naming.humanize(category), count} end)
    |> Map.new()
  end
end
