defmodule ValentineWeb.Helpers.AuthHelper do
  def init(default), do: default

  def call(conn, _) do
    if auth_active?() do
      case Plug.Conn.get_session(conn, "user_id") do
        nil ->
          conn
          |> Phoenix.Controller.redirect(to: "/")
          |> Plug.Conn.halt()

        _ ->
          conn
      end
    else
      conn
    end
  end

  def on_mount(:default, _params, session, socket) do
    if auth_active?() do
      case session["user_id"] do
        nil ->
          {:halt, Phoenix.LiveView.redirect(socket, to: "/")}

        user_id ->
          {:cont, Phoenix.Component.assign(socket, :current_user, user_id)}
      end
    else
      {:cont, Phoenix.Component.assign(socket, :current_user, nil)}
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
