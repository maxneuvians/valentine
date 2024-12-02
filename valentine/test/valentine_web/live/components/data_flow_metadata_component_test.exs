defmodule ValentineWeb.WorkspaceLive.Components.DataFlowMetadataComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.DataFlowMetadataComponent

  import Valentine.ComposerFixtures
  alias Valentine.Composer.DataFlowDiagram

  setup do
    dfd = data_flow_diagram_fixture()
    node = DataFlowDiagram.add_node(dfd.workspace_id, %{"type" => "test"})

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        element_id: node.data.id,
        workspace_id: dfd.workspace_id
      }
    }

    %{dfd: dfd, node: node, socket: socket, workspace_id: dfd.workspace_id}
  end

  test "renders properly", %{node: node, socket: socket} do
    html = render_component(DataFlowMetadataComponent, socket.assigns)
    assert html =~ node.data.id
  end

  describe "update/2" do
    test "updates the assigns with the selected node based on element_id", %{
      node: node,
      socket: socket
    } do
      {:ok, socket} = DataFlowMetadataComponent.update(socket.assigns, socket)
      assert socket.assigns.element == node
    end
  end
end
