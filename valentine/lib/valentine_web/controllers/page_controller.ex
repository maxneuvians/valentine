defmodule ValentineWeb.PageController do
  use ValentineWeb, :controller

  def home(conn, _params) do
    if auth_active?() do
      render(conn, :home, layout: false, auth: true, theme: "light")
    else
      render(conn, :home, layout: false, auth: false, theme: "light")
    end
  end

  defp auth_active?() do
    with client_id when is_binary(client_id) <- System.get_env("GOOGLE_CLIENT_ID"),
         client_secret when is_binary(client_secret) <- System.get_env("GOOGLE_CLIENT_SECRET"),
         true <- String.length(client_id) > 0,
         true <- String.length(client_secret) > 0 do
      true
    else
      _ -> false
    end
  end
end
