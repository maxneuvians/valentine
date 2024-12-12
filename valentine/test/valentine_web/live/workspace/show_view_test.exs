defmodule ValentineWeb.WorkspaceLive.ShowViewTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  defp create_workspace(_) do
    workspace = workspace_fixture()
    threat = threat_fixture()
    mitigation = mitigation_fixture()
    %{mitigation: mitigation, threat: threat, workspace: workspace}
  end

  describe "Show" do
    setup [:create_workspace]

    test "display workspace name", %{
      conn: conn,
      workspace: workspace
    } do
      {:ok, _index_live, html} = live(conn, ~p"/workspaces/#{workspace.id}")

      assert html =~ "Show Workspace"
      assert html =~ workspace.name
    end

    test "display mitigation status", %{conn: conn, mitigation: mitigation} do
      {:ok, _index_live, html} = live(conn, ~p"/workspaces/#{mitigation.workspace_id}")

      assert html =~ "Mitigation status"
      assert html =~ "[&quot;Identified&quot;]"
    end

    test "display threat prioritization", %{conn: conn, threat: threat} do
      {:ok, _index_live, html} = live(conn, ~p"/workspaces/#{threat.workspace_id}")

      assert html =~ "Threats prioritization"
      assert html =~ "[&quot;High&quot;]"
    end

    test "display threat stride", %{conn: conn, threat: threat} do
      {:ok, _index_live, html} = live(conn, ~p"/workspaces/#{threat.workspace_id}")

      assert html =~ "Threat STRIDE"
      assert html =~ "Spoofing"
    end
  end
end
