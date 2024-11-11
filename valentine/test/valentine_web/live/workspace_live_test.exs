defmodule ValentineWeb.WorkspaceLiveTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_workspace(_) do
    workspace = workspace_fixture()
    %{workspace: workspace}
  end

  describe "Index" do
    setup [:create_workspace]

    test "lists all workspaces", %{conn: conn, workspace: workspace} do
      {:ok, _index_live, html} = live(conn, ~p"/workspaces")

      assert html =~ "Listing Workspaces"
      assert html =~ workspace.name
    end

    test "saves new workspace", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/workspaces")

      assert index_live |> element("a", "New Workspace") |> render_click() =~
               "New Workspace"

      assert_patch(index_live, ~p"/workspaces/new")

      assert index_live
             |> form("#workspace-form", workspace: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#workspace-form", workspace: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/workspaces")

      html = render(index_live)
      assert html =~ "Workspace created successfully"
      assert html =~ "some name"
    end

    test "updates workspace in listing", %{conn: conn, workspace: workspace} do
      {:ok, index_live, _html} = live(conn, ~p"/workspaces")

      assert index_live |> element("#workspaces-#{workspace.id} a", "Edit") |> render_click() =~
               "Edit Workspace"

      assert_patch(index_live, ~p"/workspaces/#{workspace}/edit")

      assert index_live
             |> form("#workspace-form", workspace: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#workspace-form", workspace: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/workspaces")

      html = render(index_live)
      assert html =~ "Workspace updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes workspace in listing", %{conn: conn, workspace: workspace} do
      {:ok, index_live, _html} = live(conn, ~p"/workspaces")

      assert index_live |> element("#workspaces-#{workspace.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#workspaces-#{workspace.id}")
    end
  end

  describe "Show" do
    setup [:create_workspace]

    test "displays workspace", %{conn: conn, workspace: workspace} do
      {:ok, _show_live, html} = live(conn, ~p"/workspaces/#{workspace}")

      assert html =~ "Show Workspace"
      assert html =~ workspace.name
    end

    test "updates workspace within modal", %{conn: conn, workspace: workspace} do
      {:ok, show_live, _html} = live(conn, ~p"/workspaces/#{workspace}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Workspace"

      assert_patch(show_live, ~p"/workspaces/#{workspace}/show/edit")

      assert show_live
             |> form("#workspace-form", workspace: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#workspace-form", workspace: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/workspaces/#{workspace}")

      html = render(show_live)
      assert html =~ "Workspace updated successfully"
      assert html =~ "some updated name"
    end
  end
end
