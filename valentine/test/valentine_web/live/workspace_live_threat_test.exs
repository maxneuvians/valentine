defmodule ValentineWeb.WorkspaceLive.ThreatTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  @create_attrs %{
    threat_source: "some source",
    prerequisites: "some prerequisites",
    threat_action: "some action",
    threat_impact: "some impact",
    impacted_assets: ["option1", "option2"],
    impacted_goal: ["option1", "option2"],
  }
  @update_attrs %{
    threat_source: "some updated source",
    prerequisites: "some updated prerequisites",
    threat_action: "some updated action",
    threat_impact: "some updated impact",
    impacted_assets: ["option1", "option2"],
    impacted_goal: ["option1", "option2"],
  }
  @invalid_attrs %{threat_source: nil}

  defp create_threat(_) do
    threat = threat_fixture()
    %{threat: threat, workspace_id: threat.workspace_id}
  end

  describe "Index" do
    setup [:create_threat]

    test "lists all threats", %{conn: conn, threat: threat} do
      {:ok, _index_live, html} = live(conn, ~p"/workspaces/#{threat.workspace_id}/threats")

      assert html =~ "Listing Threats"
      assert html =~ threat.threat_source
    end

    test "saves new threat", %{conn: conn, workspace_id: workspace_id} do
      {:ok, index_live, html} = live(conn, ~p"/workspaces/#{workspace_id}/threats/new")

      assert html =~ "New Threat Statement"

      assert index_live
             |> form("#threat-form")
             |> render_submit(%{threat: @invalid_attrs}) =~ "can&#39;t be blank"

      {:ok, _, html} =
        assert index_live
               |> form("#threat-form")
               |> render_submit(%{threat: Map.merge(@create_attrs, %{workspace_id: workspace_id})})
               |> follow_redirect(conn, ~p"/workspaces/#{workspace_id}/threats")

      assert html =~ "Threat created successfully"
      assert html =~ "some source"
    end

    test "updates threat in listing", %{conn: conn, threat: threat} do
      {:ok, index_live, html} =
        live(conn, ~p"/workspaces/#{threat.workspace_id}/threats/#{threat.id}")

      assert html =~ "Edit Threat Statement"

      {:ok, _, html} =
        assert index_live
               |> form("#threat-form")
               |> render_submit(%{threat: @update_attrs})
               |> follow_redirect(conn, ~p"/workspaces/#{threat.workspace_id}/threats")

      assert html =~ "Threat updated successfully"
      assert html =~ "some updated source"
    end
  end

  describe "Show" do
    setup [:create_threat]

    test "displays threat", %{conn: conn, threat: threat} do
      {:ok, _show_live, html} =
        live(conn, ~p"/workspaces/#{threat.workspace_id}/threats/#{threat.id}")

      assert html =~ "Edit Threat Statement"
      assert html =~ threat.threat_source
    end
  end
end
