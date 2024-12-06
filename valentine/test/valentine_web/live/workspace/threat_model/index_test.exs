defmodule ValentineWeb.WorkspaceLive.ThreatModel.IndexTest do
  use ValentineWeb.ConnCase
  import Valentine.ComposerFixtures

  setup do
    workspace = workspace_fixture()

    socket =
      %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          live_action: nil,
          filters: %{},
          flash: %{}
        }
      }

    {:ok, %{workspace: workspace, socket: socket}}
  end

  describe "mount/3" do
    test "assigns workspace", %{
      socket: socket,
      workspace: workspace
    } do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.ThreatModel.Index.mount(
          %{"workspace_id" => workspace.id},
          %{},
          socket
        )

      assert socket.assigns.workspace.id == workspace.id
    end
  end

  describe "handle_params/3" do
    test "sets page title for index action", %{socket: socket} do
      socket = put_in(socket.assigns.live_action, :index)

      {:noreply, updated_socket} =
        ValentineWeb.WorkspaceLive.ThreatModel.Index.handle_params(
          %{},
          "",
          socket
        )

      assert updated_socket.assigns.page_title == "Threat model"
    end
  end
end
