defmodule ValentineWeb.WorkspaceLive.Controls.IndexTest do
  use ValentineWeb.ConnCase

  import Valentine.ComposerFixtures

  setup do
    control = control_fixture()
    workspace = workspace_fixture()

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        live_action: nil,
        flash: %{},
        workspace_id: workspace.id
      }
    }

    %{
      control: control,
      socket: socket,
      workspace_id: workspace.id
    }
  end

  describe "mount/3" do
    test "mounts the component and assigns the correct assigns", %{
      control: control,
      workspace_id: workspace_id,
      socket: socket
    } do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.Controls.Index.mount(
          %{"workspace_id" => workspace_id},
          nil,
          socket
        )

      assert socket.assigns.controls == [control]

      assert socket.assigns.workspace_id == workspace_id
    end
  end

  describe "handle_params/3 assigns the page title to :index action" do
    test "assigns the page title to 'NIST Controls' when live_action is :index" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          live_action: :index,
          flash: %{},
          workspace_id: 1
        }
      }

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.Controls.Index.handle_params(nil, nil, socket)

      assert socket.assigns.page_title == "NIST Controls"
    end
  end
end
