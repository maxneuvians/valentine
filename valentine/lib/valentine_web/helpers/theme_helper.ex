defmodule ValentineWeb.Helpers.ThemeHelper do
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    theme = session["theme"] || "dark"
    socket = assign(socket, :theme, theme)
    {:cont, socket}
  end
end
