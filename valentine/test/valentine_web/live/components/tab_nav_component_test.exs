defmodule ValentineWeb.WorkspaceLive.Components.TabNavComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.TabNavComponent

  defp setup_component(_) do
    assigns = %{
      __changed__: %{},
      id: "tab-nav-component"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  defp tab_slot() do
    [
      %{
        __slot__: :tab,
        inner_block: fn _, tab -> "Content for #{tab}" end
      }
    ]
  end

  describe "mount/1" do
    test "mounts the component with the correct assigns" do
      {:ok, socket} = TabNavComponent.mount(%Phoenix.LiveView.Socket{})

      assert socket.assigns.tabs == []
      assert socket.assigns.current_tab == ""
    end
  end

  describe "render/1" do
    setup [:setup_component]

    test "renders the component properly", %{assigns: assigns} do
      assigns =
        Map.merge(assigns, %{
          tab_content: tab_slot(),
          tabs: [%{label: "Tab 1", id: "tab-1"}, %{label: "Tab 2", id: "tab-2"}]
        })

      html = render_component(TabNavComponent, assigns)

      assert html =~ "Tab 1"
      assert html =~ "Tab 2"
      assert html =~ "Content for tab-1"
    end
  end

  describe "handle_event/3" do
    setup [:setup_component]

    test "sets the current tab", %{socket: socket} do
      socket =
        Map.merge(socket, %{
          assigns: %{__changed__: %{}, current_tab: nil}
        })

      {:noreply, socket} = TabNavComponent.handle_event("set_tab", %{"item" => "tab-1"}, socket)

      assert socket.assigns.current_tab == "tab-1"
    end
  end
end
