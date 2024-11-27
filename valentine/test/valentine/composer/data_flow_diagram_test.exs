defmodule Valentine.Composer.DataFlowDiagramTest do
  use ExUnit.Case, async: true

  alias Valentine.Composer.DataFlowDiagram

  setup do
    workspace_id = System.unique_integer([:positive])
    {:ok, workspace_id: workspace_id}
  end

  test "new/1 creates a new DataFlowDiagram", %{workspace_id: workspace_id} do
    dfd = DataFlowDiagram.new(workspace_id)
    assert %DataFlowDiagram{id: _, workspace_id: ^workspace_id, nodes: %{}, edges: %{}} = dfd
  end

  test "add_node/2 adds a new node", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    assert node[:data][:type] == "test"
    assert node[:grabbable] == "true"
    assert node[:position][:x] <= 300
    assert node[:position][:y] <= 300
  end

  test "delete/2 deletes a node", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})

    DataFlowDiagram.delete(workspace_id, %{
      "element" => %{"id" => node[:data][:id], "type" => "node"}
    })

    dfd = DataFlowDiagram.get(workspace_id)
    refute Map.has_key?(dfd.nodes, node[:data][:id])
  end

  test "delete/2 deletes an edge", %{workspace_id: workspace_id} do
    edge = %{"id" => "edge-1", "source" => "node-1", "target" => "node-2"}
    DataFlowDiagram.ehcomplete(workspace_id, %{"edge" => edge})
    DataFlowDiagram.delete(workspace_id, %{"element" => %{"id" => edge["id"], "type" => "edge"}})
    dfd = DataFlowDiagram.get(workspace_id)
    refute Map.has_key?(dfd.edges, edge["id"])
  end

  test "ehcomplete/2 adds a new edge", %{workspace_id: workspace_id} do
    edge = %{"id" => "edge-1", "source" => "node-1", "target" => "node-2"}
    new_edge = DataFlowDiagram.ehcomplete(workspace_id, %{"edge" => edge})
    assert new_edge[:data][:id] == edge["id"]
    assert new_edge[:data][:source] == edge["source"]
    assert new_edge[:data][:target] == edge["target"]
  end

  test "fit_view/2 returns lil", %{workspace_id: workspace_id} do
    assert DataFlowDiagram.fit_view(workspace_id, %{}) == nil
  end

  test "free/2 sets node grabbable to true", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    DataFlowDiagram.grab(workspace_id, %{"node" => %{"id" => node[:data][:id]}})
    updated_node = DataFlowDiagram.free(workspace_id, %{"node" => %{"id" => node[:data][:id]}})
    assert updated_node[:grabbable] == "true"
  end

  test "grab/2 sets node grabbable to false", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    updated_node = DataFlowDiagram.grab(workspace_id, %{"node" => %{"id" => node[:data][:id]}})
    assert updated_node[:grabbable] == "false"
  end

  test "position/2 updates node position", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    new_position = %{"x" => 100, "y" => 200}

    updated_node =
      DataFlowDiagram.position(workspace_id, %{
        "node" => %{"id" => node[:data][:id], "position" => new_position}
      })

    assert updated_node[:position][:x] == 100
    assert updated_node[:position][:y] == 200
  end

  test "update_label/2 updates node label", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})

    updated_node =
      DataFlowDiagram.update_label(workspace_id, %{
        "id" => node[:data][:id],
        "value" => "New Label"
      })

    assert updated_node[:data][:label] == "New Label"
  end

  test "update_label/2 updates edge label", %{workspace_id: workspace_id} do
    edge = %{"id" => "edge-1", "source" => "node-1", "target" => "node-2"}
    DataFlowDiagram.ehcomplete(workspace_id, %{"edge" => edge})

    updated_edge =
      DataFlowDiagram.update_label(workspace_id, %{"id" => edge["id"], "value" => "New Label"})

    assert updated_edge[:data][:label] == "New Label"
  end
end
