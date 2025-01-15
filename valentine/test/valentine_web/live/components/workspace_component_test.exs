defmodule ValentineWeb.WorkspaceLive.Components.WorkspaceComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  alias ValentineWeb.WorkspaceLive.Components.WorkspaceComponent

  defp create_workspace(_) do
    workspace = workspace_fixture()
    %{assigns: %{current_user: %{}, presence: %{}, workspace: workspace}}
  end

  describe "render" do
    setup [:create_workspace]

    test "displays workspace name", %{assigns: assigns} do
      html = render_component(WorkspaceComponent, assigns)
      assert html =~ assigns.workspace.name
    end
  end
end
