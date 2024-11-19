defmodule ValentineWeb.WorkspaceLive.Components.FilterComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  @impl true
  def render(assigns) do
    assigns =
      if !Map.has_key?(assigns.filters, assigns.name) do
        assign(assigns, :filters, Map.put(assigns.filters, assigns.name, []))
      else
        assigns
      end

    ~H"""
    <div class={@class}>
      <.action_menu is_dropdown_caret id={"#{@id}-dropdown"}>
        <:toggle>
          <.octicon name={"#{@icon}-16"} /><span><%= Phoenix.Naming.humanize(@name) %></span>
          <%= if is_list(@filters[@name]) && length(@filters[@name]) > 0 do %>
            <.counter>
              <%= length(@filters[@name]) %>
            </.counter>
          <% end %>
        </:toggle>
        <.action_list is_multiple_select>
          <.action_list_item is_inline_description phx-click="clear_filter" phx-target={@myself}>
            <:description><.octicon name="x-16" /> Clear all</:description>
          </.action_list_item>
          <.action_list_section_divider />
          <%= for value <- @values do %>
            <.action_list_item
              field={@name}
              checked_value={value}
              is_selected={value in @filters[@name]}
              is_multiple_select
              phx-click="select_filter"
              phx-target={@myself}
              phx-value-checked={value}
            >
              <%= Phoenix.Naming.humanize(value) %>
            </.action_list_item>
          <% end %>
        </.action_list>
      </.action_menu>
    </div>
    """
  end

  @impl true
  def handle_event("clear_filter", _params, socket) do
    %{filters: filters, name: name} = socket.assigns
    filters = Map.delete(filters, name)
    send(self(), {:update_filter, filters})
    {:noreply, assign(socket, filters: filters)}
  end

  @impl true
  def handle_event("select_filter", params, socket) do
    %{filters: filters, name: name} = socket.assigns
    value = String.to_existing_atom(params["checked"])

    filters =
      cond do
        !filters[name] ->
          Map.put(filters, name, [value])

        value in filters[name] ->
          filters =
            Map.update!(filters, name, fn values ->
              Enum.reject(values, &(&1 == value))
            end)

          if length(filters[name]) == 0 do
            Map.delete(filters, name)
          else
            filters
          end

        true ->
          Map.update!(filters, name, fn values ->
            [value | values]
          end)
      end

    send(self(), {:update_filter, filters})
    {:noreply, assign(socket, filters: filters)}
  end
end
