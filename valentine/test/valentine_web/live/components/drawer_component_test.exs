defmodule ValentineWeb.WorkspaceLive.Components.DrawerComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.DrawerComponent

  defp create_drawer(_) do
    assigns = %{
      __changed__: %{},
      open_drawer: false,
      count: 42,
      content: "content",
      id: "drawer-component",
      title: "title"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  describe "render/1" do
    setup [:create_drawer]

    test "renders the component properly", %{assigns: assigns} do
      html = render_component(DrawerComponent, assigns)
      assert html =~ "octicon"
      assert html =~ "title"
      assert html =~ "content"
      assert html =~ "42"
    end
  end

  describe "mount/1" do
    test "mounts the component with the correct assigns" do
      socket = %Phoenix.LiveView.Socket{}
      {:ok, socket} = DrawerComponent.mount(socket)
      assert socket.assigns.open_drawer == false
      assert socket.assigns.count == 0
    end
  end

  describe "handle_event/3 toggle_drawer" do
    test "toggles the open_drawer assign" do
      socket = %Phoenix.LiveView.Socket{assigns: %{__changed__: %{}, open_drawer: false}}
      {:noreply, socket} = DrawerComponent.handle_event("toggle_drawer", %{}, socket)
      assert socket.assigns.open_drawer == true
    end
  end
end
