defmodule ValentineWeb.Helpers.ControlHelperTest do
  use ValentineWeb.ConnCase

  alias ValentineWeb.Helpers.ControlHelper

  import Valentine.ComposerFixtures

  setup do
    control = control_fixture()

    socket = %Phoenix.LiveView.Socket{
      private: %{
        lifecycle: %{handle_event: []}
      }
    }

    %{socket: socket, control: control}
  end

  describe "on_mount/4" do
    test "attaches control hook", %{socket: socket} do
      {:cont, socket} = ControlHelper.on_mount("control", %{}, %{}, socket)

      assert [
               %{
                 id: :control,
                 stage: :handle_event,
                 function: _
               }
             ] = socket.private.lifecycle.handle_event
    end

    test "assigns nist_id to nil", %{socket: socket} do
      {:cont, socket} = ControlHelper.on_mount("control", %{}, %{}, socket)

      assert socket.assigns[:nist_id] == nil
    end
  end

  describe "maybe_receive_control/3" do
    test "assigns nist_id to nil when nist_id is nil", %{socket: socket} do
      {:halt, socket} =
        ControlHelper.maybe_receive_control("view_control_modal", %{"nist_id" => nil}, socket)

      assert socket.assigns[:nist_id] == nil
    end

    test "assigns nist_id to nil when nist_id is not a valid nist_id", %{socket: socket} do
      {:halt, socket} =
        ControlHelper.maybe_receive_control(
          "view_control_modal",
          %{"nist_id" => "invalid"},
          socket
        )

      assert socket.assigns[:nist_id] == nil
    end

    test "assigns nist_id to the given nist_id", %{socket: socket} do
      {:halt, socket} =
        ControlHelper.maybe_receive_control("view_control_modal", %{"nist_id" => "AB-1"}, socket)

      assert socket.assigns[:nist_id] == "AB-1"
    end

    test "continues when the event is not view_control_modal", %{socket: socket} do
      {:cont, socket} = ControlHelper.maybe_receive_control("other_event", %{}, socket)

      assert socket == socket
    end
  end
end
