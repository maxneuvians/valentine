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

  def delete(workspace_id, %{"element" => %{"id" => id, "type" => type}}) do
    dfd = get(workspace_id)

    case type do
      "node" ->
        dfd
        |> Map.update!(:nodes, &Map.delete(&1, id))
        # Remove edges connected to the node
        |> Map.update!(:edges, fn edges ->
          Enum.filter(edges, fn {_, edge} ->
            edge[:data][:source] != id and edge[:data][:target] != id
          end)
          |> Map.new()
        end)
        |> put()

      "edge" ->
        dfd
        |> Map.update!(:edges, &Map.delete(&1, id))
        |> put()
    end

    %{data: %{id: id}}
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
end
