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

  defp get_metadata(metadata, key, markdown \\ false) do
    Enum.find(metadata, fn %{"key" => k} -> k == key end)
    |> case do
      %{"value" => value} ->
        if markdown, do: MDEx.to_html!(value) |> Phoenix.HTML.raw(), else: value

      nil ->
        ""
    end
  end
end
