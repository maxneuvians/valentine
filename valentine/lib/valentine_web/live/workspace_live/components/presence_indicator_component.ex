defmodule ValentineWeb.WorkspaceLive.Components.PresenceIndicatorComponent do
  use Phoenix.Component
  use PrimerLive

  attr :active_module, :any, default: nil
  attr :current_user, :string, default: ""
  attr :presence, :map, default: %{}
  attr :workspace_id, :any, default: nil

  def render(assigns) do
    ~H"""
    <div class="presence-list">
      <ul>
        <%= for {{key, %{metas: metas}}, index} <- @presence |> Enum.with_index() do %>
          <li :if={is_active(hd(metas), @active_module, @workspace_id)} title={get_name(key, index)}>
            <.counter style={"color: #{get_colour(index)}; background-color: #{get_colour(index)}; #{get_border(key, @current_user)}"}>
              {index}
            </.counter>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  defp is_active(_, nil, nil), do: true

  defp is_active(%{workspace_id: workspace_id}, nil, workspace),
    do: workspace_id == workspace

  defp is_active(%{module: module, workspace_id: workspace_id}, active_module, workspace)
       when is_list(active_module),
       do: module in active_module && workspace_id == workspace

  defp is_active(%{module: module, workspace_id: workspace_id}, active_module, workspace),
    do: module == active_module && workspace_id == workspace

  defp get_border(key, user_id) do
    if key == user_id do
      "border: 2px solid #fff;"
    else
      ""
    end
  end

  defp get_colour(index) when index > 8, do: get_colour(index - 9)

  defp get_colour(index) do
    [
      "#2cbe4e",
      "#f9826c",
      "#fbbc05",
      "#f96233",
      "#f24e1e",
      "#dbab09",
      "#b08800",
      "#735c0f",
      "#3f2c00"
    ]
    |> Enum.at(index)
  end

  defp get_name("||" <> _key, index) do
    [
      "Adventurous Ant",
      "Bashful Bumblebee",
      "Clever Caterpillar",
      "Daring Dragonfly",
      "Eager Earwig",
      "Friendly Firefly",
      "Gentle Grasshopper",
      "Happy Hornet",
      "Inquisitive Inchworm",
      "Jolly Junebug",
      "Kindly Katydid",
      "Lively Ladybug",
      "Merry Mosquito",
      "Nice Nematode"
    ]
    |> Enum.at(index)
  end

  defp get_name(key, _index), do: key
end
