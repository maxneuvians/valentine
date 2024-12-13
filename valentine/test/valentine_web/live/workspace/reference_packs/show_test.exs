defmodule ValentineWeb.WorkspaceLive.ReferencePacks.ShowTest do
  use ValentineWeb.ConnCase

  import Valentine.ComposerFixtures

  setup do
    reference_pack_item = reference_pack_item_fixture()
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
      reference_pack_item: reference_pack_item,
      socket: socket,
      workspace_id: workspace.id
    }
  end

  describe "mount/3" do
    test "mounts the component and assigns the correct assigns", %{
      reference_pack_item: reference_pack_item,
      workspace_id: workspace_id,
      socket: socket
    } do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.ReferencePacks.Show.mount(
          %{
            "collection_id" => reference_pack_item.collection_id,
            "collection_type" => reference_pack_item.collection_type,
            "workspace_id" => workspace_id
          },
          nil,
          socket
        )

      assert socket.assigns.reference_pack == [reference_pack_item]

      assert socket.assigns.workspace_id == workspace_id
    end
  end

  describe "handle_params/3 assigns the page title to :index action" do
    test "assigns the page title to 'Reference packs' when live_action is :index" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          live_action: :show,
          flash: %{},
          workspace_id: 1
        }
      }

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.ReferencePacks.Show.handle_params(nil, nil, socket)

      assert socket.assigns.page_title == "Reference pack"
    end
  end
end
