defmodule ValentineWeb.WorkspaceLive.DataFlow.IndexTest do
  use ValentineWeb.ConnCase

  import Valentine.ComposerFixtures

  setup do
    dfd = data_flow_diagram_fixture()

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        live_action: nil,
        flash: %{},
        workspace_id: dfd.workspace_id
      }
    }

    %{dfd: dfd, socket: socket, workspace_id: dfd.workspace_id}
  end

  describe "mount/3" do
    test "assigns workspace_id and initializes dfd and selected assigns", %{
      workspace_id: workspace_id,
      dfd: dfd,
      socket: socket
    } do
      {:ok, socket} =
        ValentineWeb.WorkspaceLive.DataFlow.Index.mount(
          %{"workspace_id" => workspace_id},
          nil,
          socket
        )

      assert socket.assigns.dfd == dfd
      assert socket.assigns.selected_id == ""
      assert socket.assigns.selected_label == ""
      assert socket.assigns.workspace_id == workspace_id
    end
  end

  describe "handle_params/3 assigns the page title to :index action" do
    test "assigns the page title to 'Data flow diagram' when live_action is :index" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          live_action: :index,
          flash: %{},
          workspace_id: 1
        }
      }

      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.DataFlow.Index.handle_params(nil, nil, socket)

      assert socket.assigns.page_title == "Data flow diagram"
    end
  end

  describe "handle_event/3" do
    test "select event assigns selected_id and selected_label", %{
      socket: socket
    } do
      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.DataFlow.Index.handle_event(
          "select",
          %{"id" => "1", "label" => "Node 1"},
          socket
        )

      assert socket.assigns.selected_id == "1"
      assert socket.assigns.selected_label == "Node 1"
    end

    test "unselect event assigns empty string to selected_id and selected_label", %{
      socket: socket
    } do
      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.DataFlow.Index.handle_event(
          "unselect",
          %{},
          socket
        )

      assert socket.assigns.selected_id == ""
      assert socket.assigns.selected_label == ""
    end

    test "handles generic events and applys them to the DFD and pushes the event to the client",
         %{
           socket: socket
         } do
      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.DataFlow.Index.handle_event(
          "fit_view",
          %{},
          socket
        )

      assert socket.private == %{
               live_temp: %{
                 push_events: [["updateGraph", %{payload: nil, event: "fit_view"}]]
               }
             }
    end

    test "handles generic events and applys them to the DFD and does pushes the event to the client if it happend locally",
         %{
           socket: socket
         } do
      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.DataFlow.Index.handle_event(
          "fit_view",
          %{"localJs" => true},
          socket
        )

      assert socket.private == %{live_temp: %{}}
    end
  end

  describe "handle_info/2" do
    test "receives remote event and pushes them to the client", %{socket: socket} do
      {:noreply, socket} =
        ValentineWeb.WorkspaceLive.DataFlow.Index.handle_info(
          %{
            event: "fit_view",
            payload: nil
          },
          socket
        )

      assert socket.private == %{
               live_temp: %{
                 push_events: [["updateGraph", %{event: "fit_view", payload: nil}]]
               }
             }
    end
  end
end
