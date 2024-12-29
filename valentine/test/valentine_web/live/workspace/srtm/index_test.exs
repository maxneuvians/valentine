defmodule ValentineWeb.WorkspaceLive.SRTM.IndexTest do
  use ValentineWeb.ConnCase

  import Valentine.ComposerFixtures

  setup do
    control = control_fixture(%{nist_id: "AC-1", tags: ["A", "B", "C"]})
    workspace = workspace_fixture()

    workspace =
      Valentine.Composer.get_workspace!(workspace.id,
        mitigations: [:assumptions, :threats],
        threats: [:assumptions, :mitigations],
        assumptions: [:threats, :mitigations]
      )

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        live_action: nil,
        filters: nil,
        flash: %{},
        workspace: workspace
      }
    }

    %{
      control: control,
      socket: socket,
      workspace: workspace
    }
  end

  describe "mount/3" do
    test "mounts the component and assigns the correct assigns", %{
      control: control,
      workspace: workspace,
      socket: socket
    } do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.SRTM.Index.mount(
          %{"workspace_id" => workspace.id},
          nil,
          socket
        )

      assert socket.assigns.controls == %{
               not_allocated: %{"AC-1" => [control]},
               out_of_scope: %{},
               in_scope: %{}
             }

      assert socket.assigns.workspace.id == workspace.id
    end

    test "mounts tagged assumptions into the correct category", %{
      workspace: workspace,
      socket: socket
    } do
      assumption =
        assumption_fixture(%{
          tags: ["AC-1"],
          workspace_id: workspace.id
        })

      {:ok, socket} =
        ValentineWeb.WorkspaceLive.SRTM.Index.mount(
          %{"workspace_id" => workspace.id},
          nil,
          socket
        )

      [{_, [assigned_assumption]}] = socket.assigns.controls[:out_of_scope]["AC-1"]
      assert assigned_assumption.id == assumption.id
      assert socket.assigns.workspace.id == workspace.id
    end

    test "mounts mitigations into the correct category", %{
      workspace: workspace,
      socket: socket
    } do
      mitigation =
        mitigation_fixture(%{
          tags: ["AC-1"],
          workspace_id: workspace.id
        })

      {:ok, socket} =
        ValentineWeb.WorkspaceLive.SRTM.Index.mount(
          %{"workspace_id" => workspace.id},
          nil,
          socket
        )

      [{_, [assigned_mitigation]}] = socket.assigns.controls[:in_scope]["AC-1"]
      assert assigned_mitigation.id == mitigation.id
      assert socket.assigns.workspace.id == workspace.id
    end
  end

  describe "handle_event/3" do
    test "clears the filters", %{
      control: control,
      socket: socket
    } do
      socket = put_in(socket.assigns.filters, %{"profile" => "Profile 1"})

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.SRTM.Index.handle_event(
          "clear_filters",
          %{},
          socket
        )

      assert socket.assigns.filters == %{}

      assert socket.assigns.controls == %{
               not_allocated: %{"AC-1" => [control]},
               out_of_scope: %{},
               in_scope: %{}
             }
    end
  end

  describe "handle_info/2" do
    test "updates the filters", %{
      control: control,
      socket: socket
    } do
      socket = put_in(socket.assigns.filters, %{"profile" => "Profile 1"})

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.SRTM.Index.handle_info(
          {:update_filter, %{"profile" => control.tags}},
          socket
        )

      assert socket.assigns.filters == %{"profile" => control.tags}

      assert socket.assigns.controls == %{
               not_allocated: %{"AC-1" => [control]},
               out_of_scope: %{},
               in_scope: %{}
             }
    end
  end

  describe "handle_params/3" do
    test "applies the action", %{
      socket: socket
    } do
      socket = put_in(socket.assigns.live_action, :index)

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.SRTM.Index.handle_params(
          %{},
          nil,
          socket
        )

      assert socket.assigns.page_title == "Security Requirements Traceability Matrix"
    end
  end
end
