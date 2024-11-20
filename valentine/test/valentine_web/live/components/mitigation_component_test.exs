defmodule ValentineWeb.WorkspaceLive.Components.MitigationComponentTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  alias ValentineWeb.WorkspaceLive.Components.MitigationComponent

  defp create_mitigation(_) do
    mitigation = mitigation_fixture()
    assigns = %{__changed__: %{}, mitigation: mitigation, id: "mitigation-component"}

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  describe "render/1" do
    setup [:create_mitigation]

    test "displays mitigation numeric_id", %{assigns: assigns} do
      html = render_component(MitigationComponent, assigns)
      assert html =~ "Mitigation #{assigns.mitigation.numeric_id}"
    end

    test "displays mitigation content", %{assigns: assigns} do
      html = render_component(MitigationComponent, assigns)
      assert html =~ assigns.mitigation.content
    end

    test "displays mitigation tags", %{assigns: assigns} do
      html = render_component(MitigationComponent, assigns)
      assert html =~ hd(assigns.mitigation.tags)
    end
  end

  describe "update/2" do
    setup [:create_mitigation]

    test "assigns an empty tag", %{assigns: assigns, socket: socket} do
      {:ok, updated_socket} = MitigationComponent.update(assigns, socket)
      assert updated_socket.assigns.tag == ""
    end
  end

  describe "handle_event/3" do
    setup [:create_mitigation]

    test "adds a tag to the mitigation", %{assigns: assigns, socket: socket} do
      socket = Map.put(socket, :assigns, Map.put(assigns, :tag, "new-tag"))

      {:noreply, updated_socket} =
        MitigationComponent.handle_event("add_tag", %{}, socket)

      assert Enum.member?(updated_socket.assigns.mitigation.tags, "new-tag")
    end

    test "does nothing if tag is not set", %{assigns: assigns, socket: socket} do
      socket = Map.put(socket, :assigns, Map.delete(assigns, :tag))

      {:noreply, updated_socket} =
        MitigationComponent.handle_event("add_tag", %{}, socket)

      assert Enum.count(updated_socket.assigns.mitigation.tags) ==
               Enum.count(assigns.mitigation.tags)
    end

    test "does nothing if tag already exists", %{assigns: assigns, socket: socket} do
      socket = Map.put(socket, :assigns, Map.put(assigns, :tag, hd(assigns.mitigation.tags)))

      {:noreply, updated_socket} =
        MitigationComponent.handle_event("add_tag", %{}, socket)

      assert Enum.count(updated_socket.assigns.mitigation.tags) ==
               Enum.count(assigns.mitigation.tags)
    end

    test "removes a tag from the mitigation", %{assigns: assigns, socket: socket} do
      tag = hd(assigns.mitigation.tags)
      socket = Map.put(socket, :assigns, Map.put(assigns, :tag, tag))

      {:noreply, updated_socket} =
        MitigationComponent.handle_event("remove_tag", %{"tag" => tag}, socket)

      assert !Enum.member?(updated_socket.assigns.mitigation.tags, tag)
    end

    test "sets a tag", %{assigns: assigns, socket: socket} do
      tag = "new-tag"
      socket = Map.put(socket, :assigns, Map.put(assigns, :tag, tag))

      {:noreply, updated_socket} =
        MitigationComponent.handle_event("set_tag", %{"value" => tag}, socket)

      assert updated_socket.assigns.tag == tag
    end
  end
end
