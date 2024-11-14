defmodule ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpers do
  def join_list(list, joiner \\ "and")
  def join_list([], _joiner), do: ""
  def join_list([item], _joiner), do: to_string(item)
  def join_list([a, b], joiner), do: "#{a} #{joiner} #{b}"

  def join_list(list, joiner) do
    {initial, [last]} = Enum.split(list, -1)
    "#{Enum.join(initial, ", ")}, #{joiner} #{last}"
  end
end
