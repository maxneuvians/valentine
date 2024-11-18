defmodule ValentineWeb.WorkspaceLive.Components.FilterComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.FilterComponent

  defp create_filter(_) do
    assigns = %{
      __changed__: %{},
      class: "class",
      filters: %{filter: []},
      id: "id",
      icon: "icon",
      name: :filter,
      values: [:one, :two, :three]
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  describe "render/1" do
    setup [:create_filter]

    test "renders properly with id, class, icon, and name", %{assigns: assigns} do
      html = render_component(FilterComponent, assigns)
      assert html =~ "icon-16"
      assert html =~ "Filter"
      assert html =~ "class"
      assert html =~ "id-dropdown"
    end

    test "adds the name to filters if they are not initialized", %{assigns: assigns} do
      assigns = Map.update!(assigns, :filters, &Map.delete(&1, :filter))
      html = render_component(FilterComponent, assigns)
      assert html =~ "filter"
    end

    test "renders a counter if a filter has values", %{assigns: assigns} do
      assigns = Map.put(assigns, :filters, Map.put(assigns.filters, :filter, ["one"]))
      html = render_component(FilterComponent, assigns)
      assert html =~ "1"
    end
  end

  describe "handle_event/3" do
    setup [:create_filter]

    test "adds a new filter to the filters list", %{socket: socket} do
      {:noreply, socket} =
        FilterComponent.handle_event("select_filter", %{"checked" => "one"}, socket)

      assert socket.assigns.filters[:filter] == [:one]
    end

    test "removes a filter from the filters list", %{socket: socket} do
      socket =
        Map.put(socket, :assigns, %{__changed__: %{}, filters: %{filter: [:one]}, name: :filter})

      {:noreply, socket} =
        FilterComponent.handle_event("select_filter", %{"checked" => "one"}, socket)

      assert socket.assigns.filters[:filter] == []
    end

    test "adds an additional filter to the filters list", %{socket: socket} do
      socket =
        Map.put(socket, :assigns, %{__changed__: %{}, filters: %{filter: [:one]}, name: :filter})

      {:noreply, socket} =
        FilterComponent.handle_event("select_filter", %{"checked" => "two"}, socket)

      assert socket.assigns.filters[:filter] == [:two, :one]
    end
  end
end
