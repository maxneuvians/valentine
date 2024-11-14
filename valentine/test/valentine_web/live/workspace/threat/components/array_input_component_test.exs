defmodule ValentineWeb.WorkspaceLive.Threat.Components.ArrayInputComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Threat.Components.ArrayInputComponent

  @context %{
    title: "Threat Title",
    description: "Threat Description",
    examples: ["Example 1", "Example 2"]
  }

  @assigns %{
    id: "test-id",
    active_field: "test-field",
    current_value: ["Initial value"],
    context: @context
  }

  test "renders the component with context" do
    html = render_component(ArrayInputComponent, @assigns)

    assert html =~ @context.title
    assert html =~ @context.description
    assert html =~ "Initial value"
    assert html =~ "Example 1"
    assert html =~ "Example 2"
  end

  test "renders the component without examples" do
    assigns = Map.put(@assigns, :context, Map.put(@context, :examples, []))

    html = render_component(ArrayInputComponent, assigns)

    assert html =~ @context.title
    assert html =~ @context.description
    refute html =~ "Examples:"
  end

  describe "handle_event/3" do
    test "adds a tag to the current value" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __changed__: %{},
          current_value: ["Initial value"],
          tag: "New tag"
        }
      }

      {:noreply, socket} =
        ArrayInputComponent.handle_event(
          "add_tag",
          %{},
          socket
        )

      assert socket.assigns.current_value == ["Initial value", "New tag"]
    end
  end

  test "does not add a tag to the current value it it exists" do
    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        current_value: ["Initial value"],
        tag: "Initial value"
      }
    }

    {:noreply, socket} =
      ArrayInputComponent.handle_event(
        "add_tag",
        %{},
        socket
      )

    assert socket.assigns.current_value == ["Initial value"]
  end

  test "does nothing if tag is not set" do
    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        current_value: ["Initial value"]
      }
    }

    {:noreply, socket} =
      ArrayInputComponent.handle_event(
        "add_tag",
        %{},
        socket
      )

    assert socket.assigns.current_value == ["Initial value"]
  end

  test "removes a tag from the current value" do
    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        current_value: ["Initial value", "Tag to remove"]
      }
    }

    {:noreply, socket} =
      ArrayInputComponent.handle_event(
        "remove_tag",
        %{"tag" => "Tag to remove"},
        socket
      )

    assert socket.assigns.current_value == ["Initial value"]
  end

  test "sets the tag value" do
    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        tag: nil
      }
    }

    {:noreply, socket} =
      ArrayInputComponent.handle_event(
        "set_tag",
        %{"value" => "New tag"},
        socket
      )

    assert socket.assigns.tag == "New tag"
  end
end
