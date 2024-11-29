defmodule ValentineWeb.WorkspaceLive.Mitigation.IndexTest do
  use ValentineWeb.ConnCase
  alias Valentine.Composer
  import Mock

  import Valentine.ComposerFixtures

  setup do
    mitigation = mitigation_fixture()

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        live_action: nil,
        flash: %{},
        workspace_id: mitigation.workspace_id
      }
    }

    %{mitigation: mitigation, socket: socket, workspace_id: mitigation.workspace_id}
  end

  describe "mount/3" do
    test "assigns workspace_id and initializes mitigations collection", %{
      socket: socket,
      mitigation: mitigation
    } do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.Mitigation.Index.mount(
          %{"workspace_id" => mitigation.workspace_id},
          %{},
          socket
        )

      assert socket.assigns.workspace_id == mitigation.workspace_id
      assert Map.has_key?(socket.assigns, :mitigations)
    end
  end

  describe "handle_params/3" do
    test "sets page title for index action", %{socket: socket, workspace_id: workspace_id} do
      socket = put_in(socket.assigns.live_action, :index)

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Mitigation.Index.handle_params(
          %{"workspace_id" => workspace_id},
          "",
          socket
        )

      assert updated_socket.assigns.page_title == "Listing Mitigations"
      assert updated_socket.assigns.workspace_id == workspace_id
    end
  end

  describe "handle_info {:saved, _mitigation}" do
    test "updates mitigations collection", %{
      socket: socket,
      mitigation: mitigation
    } do
      socket = put_in(socket.assigns.live_action, :index)

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Mitigation.Index.handle_info(
          {ValentineWeb.WorkspaceLive.Mitigation.Components.FormComponent, {:saved, mitigation}},
          socket
        )

      assert updated_socket.assigns.mitigations == [mitigation]
    end
  end

  describe "handle_event delete" do
    test "successfully deletes mitigation", %{socket: socket, mitigation: mitigation} do
      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Mitigation.Index.handle_event(
          "delete",
          %{"id" => mitigation.id},
          socket
        )

      assert updated_socket.assigns.flash["info"] =~ "deleted successfully"
    end

    test "handles not found mitigation", %{socket: socket, mitigation: mitigation} do
      with_mock Composer,
        get_mitigation!: fn _id -> nil end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Mitigation.Index.handle_event(
            "delete",
            %{"id" => mitigation.id},
            socket
          )

        assert updated_socket.assigns.flash["error"] =~ "not found"
      end
    end

    test "handles delete error", %{socket: socket, mitigation: mitigation} do
      with_mock Composer,
        get_mitigation!: fn _mitigation_id -> mitigation end,
        delete_mitigation: fn _mitigation -> {:error, "some error"} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Mitigation.Index.handle_event(
            "delete",
            %{"id" => mitigation.id},
            socket
          )

        assert updated_socket.assigns.flash["error"] =~ "Failed to delete"
      end
    end
  end
end
