defmodule ValentineWeb.WorkspaceLive.Components.ControlModalComponentTest do
  use ValentineWeb.ConnCase
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.ControlModalComponent

  import Valentine.ComposerFixtures

  setup do
    control = control_fixture()

    socket = %Phoenix.LiveView.Socket{}

    %{socket: socket, control: control}
  end

  test "renders properly if a nist_id is set", %{control: control} do
    html = render_component(ControlModalComponent, %{nist_id: control.nist_id})
    assert html =~ control.nist_id
  end

  test "renders properly if a nist_id is not set" do
    html = render_component(ControlModalComponent, %{})
    refute html =~ "control-dialog"
  end

  describe "mount/1" do
    test "initializes all the assigns", %{
      socket: socket
    } do
      {:ok, socket} = ControlModalComponent.mount(socket)
      assert socket.assigns.nist_id == nil
    end
  end
end
