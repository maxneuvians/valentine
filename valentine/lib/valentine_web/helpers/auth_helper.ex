defmodule ValentineWeb.Helpers.AuthHelper do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, session, socket) do
    if auth_active?() do
      case session["user_id"] do
        nil ->
          {:halt, redirect(socket, to: "/")}

        user_id ->
          {:cont, assign(socket, :current_user, user_id)}
      end
    else
      {:cont, assign(socket, :current_user, nil)}
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
