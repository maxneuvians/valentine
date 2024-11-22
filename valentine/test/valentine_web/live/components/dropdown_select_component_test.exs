defmodule ValentineWeb.WorkspaceLive.Components.DropdownSelectComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.DropdownSelectComponent

  defp create_dropdown_select(_) do
    assigns = %{
      __changed__: %{},
      name: "name",
      search_text: "search_text",
      items: [],
      filtered_items: [],
      show_dropdown: false,
      id: "dropdown-component"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  describe "render/1" do
    setup [:create_dropdown_select]

    test "renders the component properly", %{assigns: assigns} do
      html = render_component(DropdownSelectComponent, assigns)
      assert html =~ "octicon"
      assert html =~ assigns.name <> "-dropdown"
    end

    test "if show_dropdown is true, renders the dropdown", %{assigns: assigns} do
      assigns = Map.put(assigns, :show_dropdown, true)
      html = render_component(DropdownSelectComponent, assigns)
      assert html =~ "bg-white"
    end
  end

  describe "mount/1" do
    test "mounts the component with the correct assigns" do
      socket = %Phoenix.LiveView.Socket{}
      {:ok, socket} = DropdownSelectComponent.mount(socket)
      assert socket.assigns.selected_item == nil
      assert socket.assigns.search_text == ""
      assert socket.assigns.items == []
      assert socket.assigns.filtered_items == []
      assert socket.assigns.show_dropdown == false
    end
  end

  describe "update/2" do
    test "updates the assigns with the new assigns" do
      socket = %Phoenix.LiveView.Socket{}

      assigns = %{
        selected_item: nil,
        search_text: "search_text",
        items: [],
        filtered_items: [],
        show_dropdown: false
      }

      {:ok, socket} = DropdownSelectComponent.update(assigns, socket)
      assert socket.assigns.selected_item == nil
      assert socket.assigns.search_text == "search_text"
      assert socket.assigns.items == []
      assert socket.assigns.filtered_items == []
      assert socket.assigns.show_dropdown == false
    end
  end

  describe "handle_event/3 search" do
    test "filters the items based on the search text" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          items: [
            %{id: 1, name: "One"},
            %{id: 3, name: "Two"},
            %{id: 4, name: "Three"}
          ]
        }
      }

      {:noreply, socket} =
        DropdownSelectComponent.handle_event("search", %{"value" => "one"}, socket)

      assert socket.assigns.filtered_items == [%{id: 1, name: "One"}]
    end
  end

  describe "handle_event/3 selected item" do
    test "selects the item based on the id" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          items: [
            %{id: 1, name: "One"},
            %{id: 3, name: "Two"},
            %{id: 4, name: "Three"}
          ],
          name: "name"
        }
      }

      {:noreply, socket} =
        DropdownSelectComponent.handle_event("select_item", %{"id" => 3}, socket)

      assert socket.assigns.show_dropdown == false
    end
  end

  describe "handle_event/3 toggle dropdown" do
    test "toggles the dropdown" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          show_dropdown: false
        }
      }

      {:noreply, socket} =
        DropdownSelectComponent.handle_event("toggle_dropdown", %{}, socket)

      assert socket.assigns.show_dropdown == true
    end
  end
end
