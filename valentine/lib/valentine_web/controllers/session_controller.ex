defmodule ValentineWeb.SessionController do
  use ValentineWeb, :controller

  def create(conn, %{"chatbot" => chatbot}), do: store_string(conn, :chatbot, chatbot)
  def create(conn, %{"theme" => theme}), do: store_string(conn, :theme, theme)
  def create(conn, _params), do: conn |> send_resp(400, "")

  defp store_string(conn, key, value) do
    conn
    |> put_session(key, value)
    |> send_resp(200, "")
  end
end
