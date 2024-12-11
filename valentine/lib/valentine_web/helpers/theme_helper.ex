defmodule ValentineWeb.Helpers.ThemeHelper do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(_name, _params, session, socket) do
    {:cont,
     socket
     |> attach_hook(:theme, :handle_event, &maybe_receive_theme/3)
     |> assign(:theme, Valentine.Cache.get({socket.id, :theme}) || session["theme"] || "dark")}
  end

  defp maybe_receive_theme("update_theme", %{"data" => theme}, socket) do
    Valentine.Cache.put({socket.id, :theme}, theme, expire: :timer.hours(48))

    {:halt,
     socket
     |> assign(:theme, theme)
     |> push_event("session", %{theme: theme})}
  end

  defp maybe_receive_theme(_, _, socket), do: {:cont, socket}
end
