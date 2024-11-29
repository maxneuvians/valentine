defmodule ValentineWeb.Helpers.ThemeHelper do
  use ValentineWeb, :live_view

  def on_mount(:default, _params, _session, socket) do
    socket = assign(socket, :theme, "light")
    {:cont, socket}
  end
end
