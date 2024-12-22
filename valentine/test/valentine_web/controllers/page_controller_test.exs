defmodule ValentineWeb.PageControllerTest do
  use ValentineWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Security by Design, Not by Chance."
  end

  test "GET / with auth shows a login button", %{conn: conn} do
    System.put_env("GOOGLE_CLIENT_ID", "client_id")
    System.put_env("GOOGLE_CLIENT_SECRET", "client_secret")

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Login"

    System.put_env("GOOGLE_CLIENT_ID", "")
    System.put_env("GOOGLE_CLIENT_SECRET", "")
  end

  test "GET / without auth does not show a login button", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Go to workspaces"
  end
end
