defmodule ValentineWeb.SessionController do
  use ValentineWeb, :controller

  def create(conn, %{"theme" => theme}), do: store_string(conn, :theme, theme)

  defp store_string(conn, key, value) do
    conn
    |> put_session(key, value)
    |> send_resp(200, "")
  end
end
