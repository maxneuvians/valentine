defmodule ValentineWeb.WorkspaceLive.Threat.IndexTest do
  use ValentineWeb.ConnCase
  alias Valentine.Composer
  import Mock

  @workspace_id "123"
  @threat_id "456"

  setup do
    workspace = %{id: @workspace_id, name: "Test Workspace"}
    threat = %{id: @threat_id, title: "Test Threat"}
    socket = %Phoenix.LiveView.Socket{assigns: %{__changed__: %{}, live_action: nil, flash: %{}}}
    {:ok, %{workspace: workspace, threat: threat, socket: socket}}
  end

  describe "mount/3" do
    test "assigns workspace_id and initializes threats stream", %{socket: socket} do
      with_mocks([
        {
          Composer,
          [],
          list_threats_by_workspace: fn @workspace_id -> [%{id: 1, title: "Updated Threat"}] end
        },
        {Phoenix.LiveView, [],
         stream: fn _, _, _ ->
           %{assigns: %{streams: %{threats: []}, workspace_id: @workspace_id}}
         end}
      ]) do
        {:ok, socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.mount(
            %{"workspace_id" => @workspace_id},
            %{},
            socket
          )

        assert socket.assigns.workspace_id == @workspace_id
        assert Map.has_key?(socket.assigns.streams, :threats)
      end
    end
  end

  describe "handle_params/3" do
    test "sets page title for index action", %{socket: socket} do
      socket = put_in(socket.assigns.live_action, :index)

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Index.handle_params(
          %{"workspace_id" => @workspace_id},
          "",
          socket
        )

      assert updated_socket.assigns.page_title == "Listing threats"
      assert updated_socket.assigns.workspace_id == @workspace_id
    end
  end

  describe "handle_event delete" do
    test "successfully deletes threat", %{socket: socket, threat: threat} do
      with_mock Composer,
        get_threat!: fn @threat_id -> threat end,
        delete_threat: fn _threat -> {:ok, threat} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.handle_event(
            "delete",
            %{"id" => @threat_id},
            socket
          )

        assert updated_socket.assigns.flash["info"] =~ "deleted successfully"
      end
    end

    test "handles not found threat", %{socket: socket} do
      with_mock Composer,
        get_threat!: fn _id -> nil end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.handle_event(
            "delete",
            %{"id" => @threat_id},
            socket
          )

        assert updated_socket.assigns.flash["error"] =~ "not found"
      end
    end

    test "handles delete error", %{socket: socket, threat: threat} do
      with_mock Composer,
        get_threat!: fn @threat_id -> threat end,
        delete_threat: fn _threat -> {:error, "some error"} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.handle_event(
            "delete",
            %{"id" => @threat_id},
            socket
          )

        assert updated_socket.assigns.flash["error"] =~ "Failed to delete"
      end
    end
  end

  describe "handle_info/2" do
    test "updates threats stream on workspace changes", %{socket: socket} do
      with_mocks([
        {
          Composer,
          [],
          list_threats_by_workspace: fn @workspace_id -> [%{id: 1, title: "Updated Threat"}] end
        },
        {Phoenix.LiveView, [], stream: fn _, _, _ -> %{assigns: %{streams: %{threats: []}}} end}
      ]) do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.handle_info(
            %{topic: "workspace" <> @workspace_id},
            socket
          )

        assert Map.has_key?(updated_socket.assigns.streams, :threats)
      end
    end
  end
end
