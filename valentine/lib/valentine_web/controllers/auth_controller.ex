defmodule ValentineWeb.AuthController do
  use ValentineWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    conn
    |> clear_session()
    |> put_session(:user_id, auth.uid)
    |> put_session(:live_socket_id, "users_socket:#{auth.uid}")
    |> redirect(to: ~p"/workspaces")
  end
end
