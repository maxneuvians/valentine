defmodule ValentineWeb.WorkspaceLive.Threat.ShowTest do
  use ValentineWeb.ConnCase
  alias Valentine.Composer
  import Mock

  @workspace_id "123"
  @threat_id "456"

  setup do
    workspace = %{id: @workspace_id, name: "Test Workspace"}
    threat = %{id: @threat_id, title: "Test Threat", workspace_id: @workspace_id}

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        active_field: nil,
        changeset: nil,
        live_action: nil,
        flash: %{},
        threat: nil
      }
    }

    {:ok, %{workspace: workspace, threat: threat, socket: socket}}
  end

  describe "mount/3" do
    test "assigns workspace_id and initializes threat", %{socket: socket} do
      with_mock Composer,
        change_threat: fn _ -> %Ecto.Changeset{} end do
        {:ok, socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.mount(
            %{"workspace_id" => @workspace_id},
            %{},
            socket
          )

        assert socket.assigns.workspace_id == @workspace_id
        assert socket.assigns.active_field == nil
      end
    end
  end

  describe "handle_params/3" do
    test "sets page title for new action", %{socket: socket} do
      socket = put_in(socket.assigns.live_action, :new)

      with_mock Composer,
        change_threat: fn _ -> %Ecto.Changeset{} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_params(
            %{"workspace_id" => @workspace_id},
            "",
            socket
          )

        assert updated_socket.assigns.page_title == "Create new threat statement"
      end
    end

    test "sets page title for edit action", %{socket: socket, threat: threat} do
      socket = put_in(socket.assigns.live_action, :edit)

      with_mocks([
        {Composer, [], [get_threat!: fn @threat_id -> threat end]},
        {Composer, [], [change_threat: fn _ -> %Ecto.Changeset{} end]}
      ]) do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_params(
            %{"id" => @threat_id, "workspace_id" => @workspace_id},
            "",
            socket
          )

        assert updated_socket.assigns.page_title == "Edit threat statement"
      end
    end
  end

  describe "handle_event validate" do
    test "creates new threat successfully", %{socket: socket} do
      socket = put_in(socket.assigns.threat, %Composer.Threat{workspace_id: @workspace_id})

      with_mock Composer,
        create_threat: fn _params -> {:ok, %{workspace_id: @workspace_id}} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
            "validate",
            %{"threat" => %{"title" => "New Threat"}},
            socket
          )

        assert updated_socket.assigns.flash["info"] =~ "created successfully"
      end
    end

    test "updates existing threat successfully", %{socket: socket, threat: threat} do
      socket = put_in(socket.assigns.threat, threat)

      with_mock Composer,
        update_threat: fn _threat, _params -> {:ok, threat} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
            "validate",
            %{"threat" => %{"title" => "Updated Threat"}},
            socket
          )

        assert updated_socket.assigns.flash["info"] =~ "updated successfully"
      end
    end

    test "updates existing threat unsuccessfully", %{socket: socket, threat: threat} do
      socket = put_in(socket.assigns.threat, threat)

      with_mock Composer,
        update_threat: fn _threat, _params -> {:error, %Ecto.Changeset{}} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
            "validate",
            %{"threat" => %{"title" => "Updated Threat"}},
            socket
          )

        assert updated_socket.assigns.changeset == %Ecto.Changeset{}
      end
    end
  end

  describe "handle_event show_context" do
    test "assigns active field and context", %{socket: socket} do
      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "show_context",
          %{"field" => "threat_source"},
          socket
        )

      assert updated_socket.assigns.active_field == :threat_source
      assert Map.has_key?(updated_socket.assigns, :context)
    end
  end

  describe "handle_info/2" do
    test "updates field value in changeset", %{socket: socket} do
      socket = put_in(socket.assigns.active_field, :threat_source)
      socket = put_in(socket.assigns.changeset, Ecto.Changeset.change(%Composer.Threat{}))

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_info(
          {:update_field, "New Threat"},
          socket
        )

      assert updated_socket.assigns.changeset.changes[:threat_source] == "New Threat"
    end
  end
end
