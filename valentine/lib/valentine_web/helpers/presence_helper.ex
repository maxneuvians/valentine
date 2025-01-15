defmodule ValentineWeb.Helpers.PresenceHelper do
  import Phoenix.LiveView

  def on_mount(_name, _params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Valentine.PubSub, "valentine:presence")
    end

    {:cont,
     socket
     |> Phoenix.Component.assign(:presence, Valentine.Cache.get("valentine:presence") || %{})
     |> attach_hook(:presence_update, :handle_info, &handle_info/2)}
  end

  # Sinkhole for presence_diff events as they are handled by the presence OTP process
  defp handle_info(%{event: "presence_diff"}, socket) do
    {:halt, socket}
  end

  defp handle_info(%{event: "change"}, socket) do
    {:halt,
     socket
     |> Phoenix.Component.assign(:presence, Valentine.Cache.get("valentine:presence") || %{})}
  end

  defp handle_info(_, socket), do: {:cont, socket}
end
