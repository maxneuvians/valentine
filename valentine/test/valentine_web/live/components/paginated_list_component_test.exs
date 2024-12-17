defmodule ValentineWeb.WorkspaceLive.Components.PaginatedListComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.PaginatedListComponent

  defp setup_component(_) do
    assigns = %{
      __changed__: %{},
      id: "paginated-list-component",
      title: "Paginated List Component"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  defp filters_slot do
    [
      %{
        __slot__: :filters,
        inner_block: fn _, _ -> "Filters" end
      }
    ]
  end

  defp row_slot() do
    [
      %{
        __slot__: :row,
        inner_block: fn _, item -> "Row for #{item.id}" end
      }
    ]
  end

  describe "mount/1" do
    test "mounts the component with the correct assigns" do
      {:ok, socket} = PaginatedListComponent.mount(%Phoenix.LiveView.Socket{})

      assert socket.assigns.collection == []
      assert socket.assigns.current_page == 1
      assert socket.assigns.page_size == 10
      assert socket.assigns.selectable == false
      assert socket.assigns.selected == []
      assert socket.assigns.title == ""
    end
  end

  describe "render/1" do
    setup [:setup_component]

    test "renders the component properly", %{assigns: assigns} do
      html = render_component(PaginatedListComponent, assigns)

      assert html =~ "Paginated List Component"
    end

    test "renders a row for each item in the collection", %{assigns: assigns} do
      assigns = Map.merge(assigns, %{row: row_slot(), collection: [%{id: "1"}, %{id: "2"}]})

      html =
        render_component(PaginatedListComponent, assigns)

      assert html =~ "Row for 1"
      assert html =~ "Row for 2"
    end

    test "renders the filters slot", %{assigns: assigns} do
      assigns = Map.merge(assigns, %{filters: filters_slot()})

      html =
        render_component(PaginatedListComponent, assigns)

      assert html =~ "Filters"
    end

    test "renders a checkbox if selectable is true", %{assigns: assigns} do
      assigns = Map.merge(assigns, %{row: row_slot(), selectable: true, collection: [%{id: "1"}]})

      html =
        render_component(PaginatedListComponent, assigns)

      assert html =~ "Select all"
      assert html =~ "Deselect all"
      assert html =~ "checkbox"
      assert html =~ "Row for 1"
    end

    test "renders the selected counter if there are selected items", %{assigns: assigns} do
      assigns = Map.merge(assigns, %{row: row_slot(), selected: ["1"], collection: [%{id: "1"}]})

      html =
        render_component(PaginatedListComponent, assigns)

      assert html =~ "Counter--gray"
    end

    test "render only the current page of items", %{assigns: assigns} do
      assigns =
        Map.merge(assigns, %{
          row: row_slot(),
          collection: Enum.to_list(1..20) |> Enum.map(&%{id: &1})
        })

      html =
        render_component(PaginatedListComponent, assigns)

      assert html =~ "Row for 1"
      assert html =~ "Row for 10"
      refute html =~ "Row for 11"
    end
  end

  describe "handle_event/3" do
    setup [:setup_component]

    test "change_page" do
      {:ok, socket} = PaginatedListComponent.mount(%Phoenix.LiveView.Socket{})

      {:noreply, socket} =
        PaginatedListComponent.handle_event("change_page", %{"page" => "2"}, socket)

      assert socket.assigns.current_page == 2
    end

    test "select_all", %{socket: socket} do
      socket =
        Map.put(socket, :assigns, Map.put(socket.assigns, :collection, [%{id: "1"}, %{id: "2"}]))

      {:noreply, socket} =
        PaginatedListComponent.handle_event("select_all", %{}, socket)

      assert socket.assigns.selected == ["1", "2"]
    end

    test "deselect_all", %{socket: socket} do
      socket =
        Map.put(socket, :assigns, Map.put(socket.assigns, :selected, ["1", "2"]))

      {:noreply, socket} =
        PaginatedListComponent.handle_event("deselect_all", %{}, socket)

      assert socket.assigns.selected == []
    end

    test "toggle_select removes an existing selection", %{socket: socket} do
      socket =
        Map.put(socket, :assigns, Map.put(socket.assigns, :selected, ["1"]))

      {:noreply, socket} =
        PaginatedListComponent.handle_event("toggle_select", %{"id" => "1"}, socket)

      assert socket.assigns.selected == []
    end

    test "toggle_select adds a new selection", %{socket: socket} do
      socket =
        Map.put(socket, :assigns, Map.put(socket.assigns, :selected, ["1"]))

      {:noreply, socket} =
        PaginatedListComponent.handle_event("toggle_select", %{"id" => "2"}, socket)

      assert socket.assigns.selected == ["2", "1"]
    end
  end
end
