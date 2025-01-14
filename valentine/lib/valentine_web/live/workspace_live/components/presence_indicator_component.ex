defmodule ValentineWeb.WorkspaceLive.Components.PresenceIndicatorComponent do
  use Phoenix.Component
  use PrimerLive

  attr :presence, :map, default: %{}

  def render(assigns) do
    ~H"""
    <div class="presence-list">
      <ul>
        <%= for {{key, _presence}, index} <- @presence |> Enum.with_index() do %>
          <li title={key}>
            <.counter style={"color: #{get_colour(index)}; background-color: #{get_colour(index)}"}>
              {index}
            </.counter>
          </li>
        <% end %>
      </ul>
    </div>
    """
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
end
