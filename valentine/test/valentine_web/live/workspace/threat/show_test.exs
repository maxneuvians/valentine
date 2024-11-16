defmodule ValentineWeb.WorkspaceLive.Threat.ShowTest do
  use ValentineWeb.ConnCase
  alias Valentine.Composer
  import Mock

  @workspace_id "123"
  @threat_id "456"

  setup do
    workspace = %Composer.Workspace{id: @workspace_id, name: "Test Workspace"}
    threat = %Composer.Threat{id: @threat_id, workspace_id: @workspace_id}

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        active_field: nil,
        changes: nil,
        live_action: nil,
        flash: %{},
        threat: nil,
        toggle_goals: false,
        workspace_id: nil
      }
    }

    {:ok, %{workspace: workspace, threat: threat, socket: socket}}
  end

  describe "mount/3" do
    test "assigns workspace_id and initializes view", %{socket: socket} do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.mount(
          %{"workspace_id" => @workspace_id},
          %{},
          socket
        )

      assert socket.assigns.active_type == nil
      assert socket.assigns.errors == nil
      assert socket.assigns.toggle_goals == false
      assert socket.assigns.workspace_id == @workspace_id
    end
  end

  describe "handle_params/3" do
    test "sets page title for new action", %{socket: socket} do
      socket = put_in(socket.assigns.live_action, :new)
      socket = put_in(socket.assigns.workspace_id, @workspace_id)

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_params(
          %{"workspace_id" => @workspace_id},
          "",
          socket
        )

      assert updated_socket.assigns.page_title == "Create new threat statement"
      assert updated_socket.assigns.threat == %Composer.Threat{}
      assert updated_socket.assigns.changes == %{workspace_id: @workspace_id}
    end

    test "sets page title for edit action", %{socket: socket, threat: threat} do
      socket = put_in(socket.assigns.live_action, :edit)

      with_mocks([
        {Composer, [], [get_threat!: fn @threat_id -> threat end]}
      ]) do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_params(
            %{"id" => @threat_id, "workspace_id" => @workspace_id},
            "",
            socket
          )

        assert updated_socket.assigns.page_title == "Edit threat statement"
        assert updated_socket.assigns.threat == threat
        assert updated_socket.assigns.changes == Map.from_struct(threat)
      end
    end
  end

  describe "handle_event save" do
    test "creates new threat successfully", %{socket: socket} do
      socket = put_in(socket.assigns.threat, %Composer.Threat{workspace_id: @workspace_id})

      with_mock Composer,
        create_threat: fn _params -> {:ok, %{workspace_id: @workspace_id}} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
            "save",
            %{"threat" => %{"title" => "New Threat"}},
            socket
          )

        assert updated_socket.assigns.flash["info"] =~ "created successfully"
      end
    end

    test "creates new  threat unsuccessfully", %{socket: socket} do
      socket = put_in(socket.assigns.threat, %Composer.Threat{workspace_id: @workspace_id})

      with_mock Composer,
        create_threat: fn _params -> {:error, %Ecto.Changeset{}} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
            "save",
            %{"threat" => %{"title" => "New Threat"}},
            socket
          )

        assert updated_socket.assigns.errors == %Ecto.Changeset{}.errors
      end
    end

    test "updates existing threat successfully", %{socket: socket, threat: threat} do
      socket = put_in(socket.assigns.threat, threat)

      with_mock Composer,
        update_threat: fn _threat, _params -> {:ok, threat} end do
        {:noreply, updated_socket} =
          ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
            "save",
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
            "save",
            %{"threat" => %{"title" => "Updated Threat"}},
            socket
          )

        assert updated_socket.assigns.errors == %Ecto.Changeset{}.errors
      end
    end
  end

  describe "handle_event show_context" do
    test "assigns active field and context", %{socket: socket} do
      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "show_context",
          %{"field" => "threat_source", "type" => "text"},
          socket
        )

      assert updated_socket.assigns.active_field == :threat_source
      assert updated_socket.assigns.active_type == "text"
      assert Map.has_key?(updated_socket.assigns, :context)
    end
  end

  describe "handle_event toggle_goals" do
    test "toggles goals", %{socket: socket} do
      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event("toggle_goals", %{}, socket)

      assert updated_socket.assigns.toggle_goals == true
    end
  end

  describe "handle_event update_field" do
    test "updates field value in changeset", %{socket: socket} do
      socket = put_in(socket.assigns.active_field, :threat_source)
      socket = put_in(socket.assigns.changes, %{})

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "update_field",
          %{"value" => "New Threat"},
          socket
        )

      assert updated_socket.assigns.changes[:threat_source] == "New Threat"
    end

    test "updates field value in changeset if coming from a form and is a list", %{socket: socket} do
      socket = put_in(socket.assigns.changes, %{})

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "update_field",
          %{"_target" => ["field"], "field" => ["threat"]},
          socket
        )

      assert updated_socket.assigns.changes[:field] == [:threat]
    end

    test "updates field value in changeset if coming from a form and is a list and filters false values",
         %{socket: socket} do
      socket = put_in(socket.assigns.changes, %{})

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "update_field",
          %{"_target" => ["field"], "field" => ["threat", "false"]},
          socket
        )

      assert updated_socket.assigns.changes[:field] == [:threat]
    end

    test "updates field value in changeset if coming from a form and is a binary", %{
      socket: socket
    } do
      socket = put_in(socket.assigns.changes, %{})

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "update_field",
          %{"_target" => ["field"], "field" => "Threat"},
          socket
        )

      assert updated_socket.assigns.changes[:field] == "threat"
    end

    test "updates field value in changeset if coming from a form and is a comments field", %{
      socket: socket
    } do
      socket = put_in(socket.assigns.changes, %{})

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "update_field",
          %{"_target" => ["comments"], "comments" => "Comments"},
          socket
        )

      assert updated_socket.assigns.changes[:comments] == "Comments"
    end

    test "updates field value in changeset to nil if there are no matches", %{
      socket: socket
    } do
      socket = put_in(socket.assigns.changes, %{})

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_event(
          "update_field",
          %{"_target" => ["foo"], "bar" => 2},
          socket
        )

      assert updated_socket.assigns.changes[:foo] == nil
    end
  end

  describe "handle_info/2" do
    test "updates field value in changeset", %{socket: socket} do
      socket = put_in(socket.assigns.active_field, :threat_source)
      socket = put_in(socket.assigns.changes, %{})

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.Threat.Show.handle_info(
          {"update_field", %{"value" => "New Threat"}},
          socket
        )

      assert updated_socket.assigns.changes[:threat_source] == "New Threat"
    end
  end
end
