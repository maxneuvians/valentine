defmodule ValentineWeb.WorkspaceLive.Assumption.IndexViewTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  @create_attrs %{content: "some content", workspace_id: nil}
  @update_attrs %{content: "some updated content"}
  @invalid_attrs %{content: nil}

  defp create_assumption(_) do
    assumption = assumption_fixture()
    %{assumption: assumption, workspace_id: assumption.workspace_id}
  end

  describe "Index" do
    setup [:create_assumption]

    test "lists all assumptions", %{
      conn: conn,
      assumption: assumption,
      workspace_id: workspace_id
    } do
      {:ok, _index_live, html} = live(conn, ~p"/workspaces/#{workspace_id}/assumptions")

      assert html =~ "Listing Assumptions"
      assert html =~ assumption.content
    end

    test "saves new assumptions", %{conn: conn, workspace_id: workspace_id} do
      {:ok, index_live, _html} = live(conn, ~p"/workspaces/#{workspace_id}/assumptions")

      assert index_live |> element("button", "New Assumption") |> render_click() =~
               "New Assumption"

      assert_patch(index_live, ~p"/workspaces/#{workspace_id}/assumptions/new")

      assert index_live
             |> form("#assumptions-form",
               assumption: %{@create_attrs | workspace_id: workspace_id}
             )
             |> render_submit()

      assert_patch(index_live, ~p"/workspaces/#{workspace_id}/assumptions")

      html = render(index_live)
      assert html =~ "Assumption created successfully"
      assert html =~ "some content"
    end

    test "updates assumption in listing", %{
      conn: conn,
      assumption: assumption,
      workspace_id: workspace_id
    } do
      {:ok, index_live, _html} = live(conn, ~p"/workspaces/#{workspace_id}/assumptions")

      assert index_live
             |> element("#assumption-#{assumption.id} a", assumption.content)
             |> render_click() =~
               "Edit Assumption"

      assert_patch(index_live, ~p"/workspaces/#{workspace_id}/assumptions/#{assumption}/edit")

      assert index_live
             |> form("#assumptions-form", assumptions: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/workspaces/#{workspace_id}/assumptions")

      html = render(index_live)
      assert html =~ "Assumption updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes assumption in listing", %{
      conn: conn,
      assumption: assumption,
      workspace_id: workspace_id
    } do
      {:ok, index_live, _html} = live(conn, ~p"/workspaces/#{workspace_id}/assumptions")

      assert index_live
             |> element("#assumptions-#{assumption.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#assumptions-#{assumption.id}")
    end
  end
end
