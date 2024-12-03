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
    assert node["data"]["type"] == "test"
    assert node["data"]["label"] == "Test"
    assert node["data"]["parent"] == nil
    assert node["grabbable"] == "true"
    assert node["position"]["x"] <= 400
    assert node["position"]["y"] <= 400
  end

  test "clear_dfd/2 clears the DataFlowDiagram", %{workspace_id: workspace_id} do
    DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    DataFlowDiagram.clear_dfd(workspace_id, %{})
    dfd = DataFlowDiagram.get(workspace_id)
    assert Kernel.map_size(dfd.nodes) == 0
    assert Kernel.map_size(dfd.edges) == 0
  end

  test "ehcomplete/2 adds a new edge", %{workspace_id: workspace_id} do
    edge = %{"id" => "edge-1", "source" => "node-1", "target" => "node-2"}
    new_edge = DataFlowDiagram.ehcomplete(workspace_id, %{"edge" => edge})
    assert new_edge["data"]["id"] == edge["id"]
    assert new_edge["data"]["source"] == edge["source"]
    assert new_edge["data"]["target"] == edge["target"]
  end

  test "fit_view/2 returns nil", %{workspace_id: workspace_id} do
    assert DataFlowDiagram.fit_view(workspace_id, %{}) == nil
  end

  test "free/2 sets node grabbable to true", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    DataFlowDiagram.grab(workspace_id, %{"node" => %{"id" => node["data"]["id"]}})
    updated_node = DataFlowDiagram.free(workspace_id, %{"node" => %{"id" => node["data"]["id"]}})
    assert updated_node["grabbable"] == "true"
  end

  test "grab/2 sets node grabbable to false", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    updated_node = DataFlowDiagram.grab(workspace_id, %{"node" => %{"id" => node["data"]["id"]}})
    assert updated_node["grabbable"] == "false"
  end

  test "group_nodes/2 returns and empty response if no nodes are selected", %{
    workspace_id: workspace_id
  } do
    assert DataFlowDiagram.group_nodes(workspace_id, %{"selected_elements" => %{"nodes" => %{}}}) ==
             %{node: %{}, children: []}
  end

  test "group_nodes/2 groups selected nodes", %{workspace_id: workspace_id} do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    node2 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    selected_elements = %{"nodes" => %{"node-1" => node1, "node-2" => node2}}

    grouped_nodes =
      DataFlowDiagram.group_nodes(workspace_id, %{"selected_elements" => selected_elements})

    assert grouped_nodes[:node]["data"]["type"] == "trust_boundary"
    assert grouped_nodes[:children] == Map.keys(selected_elements["nodes"])
  end

  test "merge_group/2 returns an error if none of the selected nodes are a trust boundary", %{
    workspace_id: workspace_id
  } do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    node2 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    nodes = %{}
    nodes = Map.put(nodes, node1["data"]["id"], node1["data"]["label"])
    nodes = Map.put(nodes, node2["data"]["id"], node2["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    assert DataFlowDiagram.merge_group(workspace_id, %{"selected_elements" => selected_elements}) ==
             {:error, "Only trust boundaries can be merged"}
  end

  test "merge_group/2 merges selected nodes into a trust boundary", %{workspace_id: workspace_id} do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "trust_boundary"})
    node2 = DataFlowDiagram.add_node(workspace_id, %{"type" => "trust_boundary"})
    nodes = %{}
    nodes = Map.put(nodes, node1["data"]["id"], node1["data"]["label"])
    nodes = Map.put(nodes, node2["data"]["id"], node2["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    grouped_nodes =
      DataFlowDiagram.group_nodes(workspace_id, %{"selected_elements" => selected_elements})

    node3 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    nodes = %{}
    nodes = Map.put(nodes, node3["data"]["id"], node3["data"]["label"])

    nodes =
      Map.put(nodes, grouped_nodes[:node]["data"]["id"], grouped_nodes[:node]["data"]["label"])

    selected_elements = %{"nodes" => nodes}

    merged_group =
      DataFlowDiagram.merge_group(workspace_id, %{"selected_elements" => selected_elements})

    assert merged_group[:node] == grouped_nodes[:node]["data"]["id"]
    assert merged_group[:children] == [node3["data"]["id"]]
    assert merged_group[:purge] == []
  end

  test "merge_group/2 merges two selected trust boundaries", %{workspace_id: workspace_id} do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    node2 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    nodes = %{}
    nodes = Map.put(nodes, node1["data"]["id"], node1["data"]["label"])
    nodes = Map.put(nodes, node2["data"]["id"], node2["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    group1 =
      DataFlowDiagram.group_nodes(workspace_id, %{"selected_elements" => selected_elements})

    node3 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    node4 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    nodes = %{}
    nodes = Map.put(nodes, node3["data"]["id"], node3["data"]["label"])
    nodes = Map.put(nodes, node4["data"]["id"], node4["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    group2 =
      DataFlowDiagram.group_nodes(workspace_id, %{"selected_elements" => selected_elements})

    nodes = %{}
    nodes = Map.put(nodes, group1[:node]["data"]["id"], group1[:node]["data"]["label"])
    nodes = Map.put(nodes, group2[:node]["data"]["id"], group2[:node]["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    merged_group =
      DataFlowDiagram.merge_group(workspace_id, %{"selected_elements" => selected_elements})

    assert merged_group[:node] == group1[:node]["data"]["id"] || group2[:node]["data"]["id"]

    assert merged_group[:children] == [node1["data"]["id"], node2["data"]["id"]] ||
             [node3["data"]["id"], node4["data"]["id"]]

    assert merged_group[:purge] == [group2[:node]["data"]["id"]] || [group1[:node]["data"]["id"]]
  end

  test "position/2 updates node position", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    new_position = %{"x" => 100, "y" => 200}

    updated_node =
      DataFlowDiagram.position(workspace_id, %{
        "node" => %{"id" => node["data"]["id"], "position" => new_position}
      })

    assert updated_node["position"]["x"] == 100
    assert updated_node["position"]["y"] == 200
  end

  test "remove_elements/2 deletes selected nodes and edges", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    edge = %{"id" => "edge-1", "source" => "node-1", "target" => "node-2"}
    DataFlowDiagram.ehcomplete(workspace_id, %{"edge" => edge})

    selected_elements = %{"nodes" => %{"node-1" => node}, "edges" => %{"edge-1" => edge}}

    removed_elements =
      DataFlowDiagram.remove_elements(workspace_id, %{"selected_elements" => selected_elements})

    assert removed_elements["nodes"] == %{"node-1" => node}
    assert removed_elements["edges"] == %{"edge-1" => edge}

    dfd = DataFlowDiagram.get(workspace_id)
    assert Kernel.map_size(dfd.nodes) == 1
    assert Kernel.map_size(dfd.edges) == 0
  end

  test "remove_elements/2 deletes nodes and edges inside a group", %{workspace_id: workspace_id} do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    node2 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    edge = %{"id" => "edge-1", "source" => node1["data"]["id"], "target" => node2["data"]["id"]}
    DataFlowDiagram.ehcomplete(workspace_id, %{"edge" => edge})
    nodes = %{}
    nodes = Map.put(nodes, node1["data"]["id"], node1["data"]["label"])
    nodes = Map.put(nodes, node2["data"]["id"], node2["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    grouped_nodes =
      DataFlowDiagram.group_nodes(workspace_id, %{"selected_elements" => selected_elements})

    nodes = %{}

    nodes =
      Map.put(nodes, grouped_nodes[:node]["data"]["id"], grouped_nodes[:node]["data"]["label"])

    selected_elements = %{"nodes" => nodes, "edges" => %{}}

    DataFlowDiagram.remove_elements(workspace_id, %{"selected_elements" => selected_elements})

    dfd = DataFlowDiagram.get(workspace_id)
    assert Kernel.map_size(dfd.nodes) == 0
    assert Kernel.map_size(dfd.edges) == 0
  end

  test "remove_group/2 returns an error if only one node is selected", %{
    workspace_id: workspace_id
  } do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    node2 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    nodes = %{}
    nodes = Map.put(nodes, node1["data"]["id"], node1["data"]["label"])
    nodes = Map.put(nodes, node2["data"]["id"], node2["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    assert DataFlowDiagram.remove_group(workspace_id, %{"selected_elements" => selected_elements}) ==
             {:error, "Only one trust boundaries can be removed at a time"}
  end

  test "remove_group/2 returns an error if something other than a trust boundary is removed", %{
    workspace_id: workspace_id
  } do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    nodes = %{}
    nodes = Map.put(nodes, node1["data"]["id"], node1["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    assert DataFlowDiagram.remove_group(workspace_id, %{"selected_elements" => selected_elements}) ==
             {:error, "Only trust boundaries can be removed"}
  end

  test "remove_group/2 removes a parent from a set of nodes and removes the parent", %{
    workspace_id: workspace_id
  } do
    node1 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    node2 = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    nodes = %{}
    nodes = Map.put(nodes, node1["data"]["id"], node1["data"]["label"])
    nodes = Map.put(nodes, node2["data"]["id"], node2["data"]["label"])
    selected_elements = %{"nodes" => nodes}

    grouped_nodes =
      DataFlowDiagram.group_nodes(workspace_id, %{"selected_elements" => selected_elements})

    nodes = %{}

    nodes =
      Map.put(nodes, grouped_nodes[:node]["data"]["id"], grouped_nodes[:node]["data"]["label"])

    selected_elements = %{"nodes" => nodes}

    DataFlowDiagram.remove_group(workspace_id, %{"selected_elements" => selected_elements})

    dfd = DataFlowDiagram.get(workspace_id)
    assert Kernel.map_size(dfd.nodes) == 2
    assert Kernel.map_size(dfd.edges) == 0
    refute Map.has_key?(dfd.nodes, grouped_nodes[:node]["data"]["id"])
  end

  test "update_metadata/2 updates node metadata", %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    new_metadata = %{"id" => node["data"]["id"], "field" => "label", "value" => "New Label"}

    resp =
      DataFlowDiagram.update_metadata(
        workspace_id,
        new_metadata
      )

    assert resp == %{"id" => node["data"]["id"], "field" => "label", "value" => "New Label"}

    dfd = DataFlowDiagram.get(workspace_id)
    updated_node = Map.get(dfd.nodes, node["data"]["id"])

    assert updated_node["data"]["label"] == "New Label"
  end

  test "update_metadata/2 updates node metadata with a boolean value if value is missing (ex: checkbox boolean)",
       %{workspace_id: workspace_id} do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    new_metadata = %{"id" => node["data"]["id"], "field" => "checked"}

    resp =
      DataFlowDiagram.update_metadata(
        workspace_id,
        new_metadata
      )

    assert resp == %{"id" => node["data"]["id"], "field" => "checked", "value" => "false"}

    dfd = DataFlowDiagram.get(workspace_id)
    updated_node = Map.get(dfd.nodes, node["data"]["id"])

    assert updated_node["data"]["checked"] == "false"
  end

  test "update_metadata/2 updates node metadata with multiselect checks", %{
    workspace_id: workspace_id
  } do
    node = DataFlowDiagram.add_node(workspace_id, %{"type" => "test"})
    new_metadata = %{"id" => node["data"]["id"], "field" => "data_tags", "checked" => "a"}

    resp =
      DataFlowDiagram.update_metadata(
        workspace_id,
        new_metadata
      )

    assert resp == %{"id" => node["data"]["id"], "field" => "data_tags", "value" => ["a"]}

    dfd = DataFlowDiagram.get(workspace_id)
    updated_node = Map.get(dfd.nodes, node["data"]["id"])

    assert updated_node["data"]["data_tags"] == ["a"]

    # Test removing a value

    DataFlowDiagram.update_metadata(
      workspace_id,
      new_metadata
    )

    dfd = DataFlowDiagram.get(workspace_id)
    updated_node = Map.get(dfd.nodes, node["data"]["id"])

    assert updated_node["data"]["data_tags"] == []
  end

  test "zoom_in/2 returns nil", %{workspace_id: workspace_id} do
    assert DataFlowDiagram.zoom_in(workspace_id, %{}) == nil
  end

  test "zoom_out/2 returns nil", %{workspace_id: workspace_id} do
    assert DataFlowDiagram.zoom_out(workspace_id, %{}) == nil
  end
end
