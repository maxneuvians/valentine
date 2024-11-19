defmodule ValentineWeb.WorkspaceLive.Threat.IndexTest do
  use ValentineWeb.ConnCase
  alias Valentine.Composer
  import Mock

  @workspace_id "123"
  @threat_id "456"

  setup do
    workspace = %{id: @workspace_id, name: "Test Workspace"}
    threat = %{id: @threat_id, title: "Test Threat"}

    socket =
      %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          live_action: nil,
          filters: %{},
          flash: %{},
          workspace_id: @workspace_id
        }
      }

    {:ok, %{workspace: workspace, threat: threat, socket: socket}}
  end

  describe "mount/3" do
    test "assigns workspace_id and initializes threats stream", %{
      socket: socket,
      threat: threat,
      workspace: workspace
    } do
      with_mocks([
        {
          Composer,
          [],
          get_workspace!: fn @workspace_id -> workspace end
        },
        {
          Composer,
          [],
          list_threats_by_workspace: fn @workspace_id, _ -> [threat] end
        }
      ]) do
        {:ok, socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.mount(
            %{"workspace_id" => @workspace_id},
            %{},
            socket
          )

        assert socket.assigns.workspace_id == @workspace_id
        assert Map.has_key?(socket.assigns, :threats)
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
      with_mocks([
        {
          Composer,
          [],
          get_threat!: fn _threat_id -> threat end
        },
        {
          Composer,
          [],
          delete_threat: fn _threat_id -> {:ok, threat} end
        },
        {
          Composer,
          [],
          list_threats_by_workspace: fn _, _ -> [] end
        }
      ]) do
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

  describe "handle_event/3" do
    test "clears filters", %{socket: socket} do
      with_mocks([
        {
          Composer,
          [],
          list_threats_by_workspace: fn @workspace_id, _ ->
            [%{id: 1, title: "Updated Threat"}]
          end
        }
      ]) do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.handle_event(
            "clear_filters",
            nil,
            socket
          )

        assert updated_socket.assigns.filters == %{}
      end
    end
  end

  describe "handle_info/2" do
    test "updates filters on filter changes", %{socket: socket} do
      with_mocks([
        {
          Composer,
          [],
          list_threats_by_workspace: fn @workspace_id, _ ->
            [%{id: 1, title: "Updated Threat"}]
          end
        }
      ]) do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.handle_info(
            {:update_filter, %{status: "open"}},
            socket
          )

        assert updated_socket.assigns.filters == %{status: "open"}
      end
    end

    test "updates threats stream on workspace changes", %{socket: socket} do
      with_mocks([
        {
          Composer,
          [],
          list_threats_by_workspace: fn @workspace_id, _ ->
            [%{id: 1, title: "Updated Threat"}]
          end
        }
      ]) do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Index.handle_info(
            %{topic: "workspace_" <> @workspace_id},
            socket
          )

        assert Map.has_key?(updated_socket.assigns, :threats)
      end
    end
  end
end
