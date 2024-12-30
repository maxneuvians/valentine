defmodule ValentineWeb.WorkspaceLive.Components.DropdownSelectComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def render(assigns) do
    ~H"""
    <div>
      <div class="relative">
        <.text_input
          name={@name <> "-dropdown"}
          value={@search_text}
          phx-keyup="search"
          phx-target={@myself}
          phx-click="toggle_dropdown"
        >
          <:leading_visual>
            <.octicon name="search-16" />
          </:leading_visual>
        </.text_input>

        <%= if @show_dropdown do %>
          <div class="absolute w-full mt-1 bg-white border rounded-md shadow-lg z-10">
            <%= for item <- @filtered_items do %>
              <div
                class="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                phx-click="select_item"
                phx-value-id={item.id}
                phx-target={@myself}
              >
                {item.name}
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     assign(socket,
       selected_item: nil,
       search_text: "",
       items: [],
       filtered_items: [],
       show_dropdown: false
     )}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:filtered_items, assigns.items)}
  end

  def handle_event("search", %{"value" => search_text}, socket) do
    filtered_items =
      socket.assigns.items
      |> Enum.filter(
        &String.contains?(
          String.downcase(&1.name),
          String.downcase(search_text)
        )
      )

    {:noreply,
     socket
     |> assign(search_text: search_text)
     |> assign(filtered_items: filtered_items)
     |> assign(show_dropdown: true)}
  end

  def handle_event("select_item", %{"id" => id}, socket) do
    selected_item = Enum.find(socket.assigns.items, &(&1.id == id))

    send(self(), {socket.assigns.name, :selected_item, selected_item})

    {:noreply,
     socket
     |> assign(show_dropdown: false)}
  end

  def handle_event("toggle_dropdown", _, socket) do
    {:noreply, assign(socket, :show_dropdown, !socket.assigns.show_dropdown)}
  end
end
