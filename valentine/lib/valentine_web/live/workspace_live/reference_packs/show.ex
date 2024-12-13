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
     |> assign(:workspace_id, workspace_id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Reference pack")
  end
end
