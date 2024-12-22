defmodule ValentineWeb.SessionControllerTest do
  use ValentineWeb.ConnCase

  test "POST /session can set a chatbot session variable", %{conn: conn} do
    conn = post(conn, ~p"/session", %{"chatbot" => "open"})
    assert response(conn, 200) == ""
    assert get_session(conn, :chatbot) == "open"
  end

  test "POST /session can set a locale session variable", %{conn: conn} do
    conn = post(conn, ~p"/session", %{"locale" => "de"})
    assert response(conn, 200) == ""
    assert get_session(conn, :locale) == "de"
  end

  test "POST /session can set a theme session variable", %{conn: conn} do
    conn = post(conn, ~p"/session", %{"theme" => "light"})
    assert response(conn, 200) == ""
    assert get_session(conn, :theme) == "light"
  end

  test "POST /session cannot set an arbitraty session variable", %{conn: conn} do
    conn = post(conn, ~p"/session", %{"foo" => "bar"})
    assert response(conn, 400) == ""
    assert get_session(conn, :foo) != "bar"
  end
end
