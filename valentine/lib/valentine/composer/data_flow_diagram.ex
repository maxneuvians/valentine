defmodule Valentine.Composer.DataFlowDiagram do
  defstruct [
    :id,
    :workspace_id,
    :nodes,
    :edges
  ]

  alias Valentine.Cache

  def new(workspace_id) do
    %Valentine.Composer.DataFlowDiagram{
      id: System.unique_integer([:positive]),
      workspace_id: workspace_id,
      nodes: %{},
      edges: %{}
    }
  end

  def add_node(workspace_id, %{"type" => type}) do
    dfd = get(workspace_id)

    id = "node-" <> Integer.to_string(System.unique_integer([:positive]))

    node =
      %{
        data: %{
          id: id,
          label: Phoenix.Naming.humanize(type),
          parent: nil,
          type: type
        },
        grabbable: "true",
        position: %{
          x: :rand.uniform(300),
          y: :rand.uniform(300)
        }
      }

    dfd
    |> Map.update!(:nodes, &Map.put(&1, id, node))
    |> put()

    node
  end

  def clear_dfd(workspace_id, _params) do
    new(workspace_id) |> put()
    nil
  end

  def ehcomplete(workspace_id, %{"edge" => edge}) do
    dfd = get(workspace_id)

    new_edge =
      %{
        data: %{
          id: edge["id"],
          label: edge["id"],
          source: edge["source"],
          target: edge["target"]
        }
      }

    dfd
    |> Map.update!(:edges, &Map.put(&1, edge["id"], new_edge))
    |> put()

    new_edge
  end

  def fit_view(_workspace_id, _params) do
    nil
  end

  def free(workspace_id, %{"node" => node}) do
    dfd = get(workspace_id)

    new_node =
      %{
        dfd.nodes[node["id"]]
        | grabbable: "true"
      }

    dfd
    |> Map.update!(:nodes, &Map.put(&1, node["id"], new_node))
    |> put()

    new_node
  end

  def get(workspace_id) do
    case Cache.get({__MODULE__, :dfd, workspace_id}) do
      nil -> new(workspace_id) |> put()
      dfd -> dfd
    end
  end

  def grab(workspace_id, %{"node" => node}) do
    dfd = get(workspace_id)

    new_node =
      %{
        dfd.nodes[node["id"]]
        | grabbable: "false"
      }

    dfd
    |> Map.update!(:nodes, &Map.put(&1, node["id"], new_node))
    |> put()

    new_node
  end

  def group_nodes(_worskspace_id, %{"selected_elements" => %{"nodes" => nodes}})
      when nodes == %{} do
    %{node: %{}, children: []}
  end

  def group_nodes(workspace_id, %{"selected_elements" => selected_elements}) do
    dfd = get(workspace_id)
    parent_node = add_node(workspace_id, %{"type" => "trust_boundary"})

    dfd
    |> Map.update!(:nodes, fn nodes ->
      Enum.reduce(selected_elements["nodes"], nodes, fn {id, _}, acc ->
        if Map.has_key?(acc, id) do
          # Put parent id in node.data
          Map.put(acc, id, %{
            acc[id]
            | data: %{
                acc[id].data
                | parent: parent_node.data.id
              }
          })
        else
          acc
        end
      end)
    end)
    |> Map.update!(:nodes, &Map.put(&1, parent_node.data.id, parent_node))
    |> put()

    %{node: parent_node, children: Map.keys(selected_elements["nodes"])}
  end

  def merge_group(workspace_id, %{"selected_elements" => %{"nodes" => nodes}}) do
    dfd = get(workspace_id)
    # Check if any of the selected nodes is a trust boundary if not return an error
    if Enum.any?(nodes, fn {id, _} -> dfd.nodes[id].data.type == "trust_boundary" end) do
      # Get all nodes that are trust boundaries
      [
        {trust_boundary_id, _}
        | other_boundaries
      ] =
        Enum.filter(nodes, fn {id, _} -> dfd.nodes[id].data.type == "trust_boundary" end)

      trust_boundary = dfd.nodes[trust_boundary_id]

      # Get all the selected elements that do not belong to that trust boundary
      to_merge =
        Enum.filter(nodes, fn {id, _} ->
          dfd.nodes[id].data.type != "trust_boundary" and
            dfd.nodes[id].data.parent != trust_boundary.data.id
        end)

      # Get all the children that belong to the other trust boundaries
      children =
        Enum.reduce(other_boundaries, [], fn {id, _}, acc ->
          acc ++
            find_children(dfd.nodes, id)
        end)

      # Update the to_merge and children to have the parent of the trust boundary
      dfd =
        (to_merge ++ children)
        |> Enum.reduce(dfd, fn {id, _}, acc ->
          acc
          |> Map.update!(
            :nodes,
            &Map.put(&1, id, %{
              acc.nodes[id]
              | data: %{
                  acc.nodes[id].data
                  | parent: trust_boundary.data.id
                }
            })
          )
        end)

      # Remove the other trust boundaries
      other_boundaries
      |> Enum.reduce(dfd, fn {id, _}, acc ->
        acc
        |> Map.update!(:nodes, &Map.delete(&1, id))
      end)
      |> put()

      %{
        node: trust_boundary.data.id,
        children: Map.keys(Map.new(to_merge ++ children)),
        purge: Map.keys(Map.new(other_boundaries))
      }
    else
      {:error, "Only trust boundaries can be merged"}
    end
  end

  def position(workspace_id, %{"node" => node}) do
    dfd = get(workspace_id)

    new_node =
      %{
        dfd.nodes[node["id"]]
        | position: %{
            x: node["position"]["x"],
            y: node["position"]["y"]
          }
      }

    dfd
    |> Map.update!(:nodes, &Map.put(&1, node["id"], new_node))
    |> put()

    new_node
  end

  def put(dfd) do
    Cache.put({__MODULE__, :dfd, dfd.workspace_id}, dfd)
    dfd
  end

  def remove_elements(workspace_id, %{"selected_elements" => selected_elements}) do
    dfd = get(workspace_id)

    dfd =
      selected_elements["nodes"]
      |> Enum.reduce(dfd, &remove_node_and_associated_edges/2)
      |> put()

    selected_elements["edges"]
    |> Enum.reduce(dfd, fn {id, _}, acc ->
      acc
      |> Map.update!(:edges, &Map.delete(&1, id))
    end)
    |> put()

    selected_elements
  end

  def remove_group(_workspace_id, %{
        "selected_elements" => %{"nodes" => nodes}
      })
      when map_size(nodes) != 1 do
    {:error, "Only one trust boundaries can be removed at a time"}
  end

  def remove_group(workspace_id, %{"selected_elements" => %{"nodes" => nodes}}) do
    dfd = get(workspace_id)
    node = dfd.nodes[Map.keys(nodes) |> List.first()]

    if node.data.type == "trust_boundary" do
      dfd.nodes
      |> Enum.filter(fn {_, n} -> n.data.parent == node.data.id end)
      |> Enum.reduce(dfd, fn {id, n}, acc ->
        acc
        |> Map.update!(
          :nodes,
          &Map.put(&1, id, %{
            n
            | data: %{
                n.data
                | parent: nil
              }
          })
        )
      end)
      |> Map.update!(:nodes, &Map.delete(&1, node.data.id))
      |> put()

      node
    else
      {:error, "Only trust boundaries can be removed"}
    end
  end

  def update_label(workspace_id, %{"id" => id, "value" => value}) do
    dfd = get(workspace_id)

    if String.starts_with?(id, "node") do
      new_node =
        %{
          dfd.nodes[id]
          | data: %{
              dfd.nodes[id].data
              | label: value
            }
        }

      dfd
      |> Map.update!(:nodes, &Map.put(&1, id, new_node))
      |> put()

      new_node
    else
      new_edge =
        %{
          dfd.edges[id]
          | data: %{
              dfd.edges[id].data
              | label: value
            }
        }

      dfd
      |> Map.update!(:edges, &Map.put(&1, id, new_edge))
      |> put()

      new_edge
    end
  end

  defp find_children(nodes, parent_id) do
    nodes
    |> Enum.filter(fn {_, node} -> node.data.parent == parent_id end)
  end

  defp find_descendents(nodes, parent_id) do
    nodes
    |> Enum.reduce([parent_id], fn {node_id, node}, acc ->
      case node.data do
        %{parent: ^parent_id} ->
          [node_id | acc ++ find_descendents(nodes, node_id)]

        _ ->
          acc
      end
    end)
    |> Enum.uniq()
  end

  defp remove_node_and_associated_edges({id, _}, dfd) do
    find_descendents(dfd.nodes, id)
    |> Enum.reduce(dfd, fn node_id, acc ->
      acc
      |> Map.update!(:nodes, &Map.delete(&1, node_id))
      |> Map.update!(:edges, fn edges ->
        Enum.filter(edges, fn {_, edge} ->
          edge[:data][:source] != node_id and edge[:data][:target] != node_id
        end)
        |> Map.new()
      end)
    end)
  end
end
