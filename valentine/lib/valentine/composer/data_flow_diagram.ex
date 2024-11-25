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

  def add_node(workspace_id, _params) do
    dfd = get(workspace_id)

    id = Integer.to_string(System.unique_integer([:positive]))

    node =
      %{
        data: %{
          id: id,
          label: "Node #{length(Map.keys(dfd.nodes)) + 1}"
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

  def add_edge(dfd, edge) do
    new_edges = dfd.edges ++ [edge]

    %Valentine.Composer.DataFlowDiagram{
      dfd
      | edges: new_edges
    }
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
    case Cache.get({__MODULE__, workspace_id}) do
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
    Cache.put({__MODULE__, dfd.workspace_id}, dfd)
    dfd
  end
end
