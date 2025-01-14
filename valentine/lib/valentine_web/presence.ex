defmodule ValentineWeb.Presence do
  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: Valentine.PubSub

  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  def handle_metas(_topic, %{joins: joins, leaves: leaves}, _presences, state) do
    presence =
      (Valentine.Cache.get("valentine:presence") || %{})
      |> Map.merge(joins)
      |> Map.drop(Map.keys(leaves))

    Valentine.Cache.put("valentine:presence", presence)
    {:ok, state}
  end
end
