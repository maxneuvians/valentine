defmodule ValentineWeb.WorkspaceLive.Components.LabelSelectComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def render(assigns) do
    ~H"""
    <div class="float-left">
      <div class="relative ">
        <div class="mt-1 ml-2" phx-click="toggle_dropdown" phx-target={@myself}>
          <.state_label is_small class={get_class(@items, @value)}>
            <.octicon name={@icon} /> {if @value == nil,
              do: @default_value,
              else: Phoenix.Naming.humanize(@value)}
          </.state_label>
        </div>
        <%= if @show_dropdown do %>
          <div class="ActionMenu">
            <div class="ActionMenu-modal">
              <%= for {item, _} <- @items do %>
                <div
                  class="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                  phx-click="select_item"
                  phx-value-id={item}
                  phx-target={@myself}
                >
                  {Phoenix.Naming.humanize(item)}
                </div>
              <% end %>
            </div>
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
       items: [],
       show_dropdown: false
     )}
  end

  def handle_event("select_item", %{"id" => id}, socket) do
    if Map.has_key?(socket.assigns, :parent_id) do
      send_update(
        socket.assigns.parent_id,
        selected_label_dropdown: {socket.assigns.id, socket.assigns.field, id}
      )
    else
      send(self(), {:selected_label_dropdown, socket.assigns.id, socket.assigns.field, id})
    end

    {:noreply,
     socket
     |> assign(show_dropdown: false)}
  end

  def handle_event("toggle_dropdown", _, socket) do
    {:noreply, assign(socket, :show_dropdown, !socket.assigns.show_dropdown)}
  end

  defp get_class(items, value) do
    items
    |> Enum.find(fn {v, _} -> v == value end)
    |> case do
      nil -> ""
      {_, class} -> class
    end
  end
end
