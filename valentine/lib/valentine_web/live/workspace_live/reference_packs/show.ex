defmodule ValentineWeb.WorkspaceLive.ReferencePacks.Show do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(
        %{
          "collection_id" => collection_id,
          "collection_type" => collection_type,
          "workspace_id" => workspace_id
        } = _params,
        _session,
        socket
      ) do
    {:ok,
     socket
     |> assign(
       :reference_pack,
       Composer.list_reference_pack_items_by_collection(collection_id, collection_type)
     )
     |> assign(:selected_references, [])
     |> assign(:workspace_id, workspace_id)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Reference pack")}
  end

  @impl true
  def handle_event("add_references", _params, socket) do
    total =
      socket.assigns.selected_references
      |> Enum.map(&Composer.get_reference_pack_item!/1)
      |> Enum.reduce(0, fn reference_pack_item, acc ->
        case Composer.add_reference_pack_item_to_workspace(
               socket.assigns.workspace_id,
               reference_pack_item
             ) do
          {:ok, _} -> acc + 1
          {:error, _} -> acc
        end
      end)

    {:noreply,
     socket
     |> put_flash(:info, "Added #{total} reference items to workspace")
     |> push_navigate(to: ~p"/workspaces/#{socket.assigns.workspace_id}/reference_packs")}
  end

  @impl true
  def handle_info({:selected, selected_references}, socket) do
    {:noreply, assign(socket, :selected_references, selected_references)}
  end

  defp cast_keys_to_atoms(map) do
    Enum.reduce(map, %{}, fn {k, v}, acc -> Map.put(acc, String.to_existing_atom(k), v) end)
  end
end
