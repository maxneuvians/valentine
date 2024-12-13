defmodule ValentineWeb.WorkspaceLive.Components.PaginatedListComponent do
  use ValentineWeb, :live_component

  use PrimerLive

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:collection, [])
     |> assign(:current_page, 1)
     |> assign(:page_size, 10)
     |> assign(:selectable, false)
     |> assign(:selected, [])
     |> assign(:title, "")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.box id={@id}>
        <:header>{@title}</:header>
        <:row
          :for={item <- slice_collection(assigns)}
          class="d-flex flex-items-center flex-justify-between"
        >
          <div class="clearfix width-full">
            <div :if={@selectable} class="float-left">
              <.checkbox
                id={item.id}
                name={item.id}
                value={item.id}
                checked={@selected |> Enum.member?(item.id)}
              >
                <:label></:label>
              </.checkbox>
            </div>
            <div class="float-left">
              {render_slot(@row, item)}
            </div>
          </div>
        </:row>
      </.box>
      <ValentineWeb.WorkspaceLive.Components.PaginationComponent.pagination
        page_count={length(@collection) / @page_size}
        current_page={@current_page}
        link_path={fn page_num -> page_num end}
      />
    </div>
    """
  end

  defp slice_collection(%{
         collection: collection,
         current_page: current_page,
         page_size: page_size
       }) do
    Enum.slice(collection, (current_page - 1) * page_size, page_size)
  end

  defp slice_collection(_), do: []
end
