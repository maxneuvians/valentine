defmodule ValentineWeb.WorkspaceLive.SRTM.IndexViewTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  setup do
    control = control_fixture()
    workspace = workspace_fixture()

    %{
      control: control,
      workspace_id: workspace.id
    }
  end

  describe "Index" do
    test "lists all controls", %{
      conn: conn,
      control: control,
      workspace_id: workspace_id
    } do
      {:ok, _index_live, html} =
        live(
          conn,
          ~p"/workspaces/#{workspace_id}/srtm"
        )

      assert html =~ "Security Requirements Traceability Matrix"
      assert html =~ control.name
      assert html =~ control.nist_id
    end
  end
end
