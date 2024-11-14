defmodule ValentineWeb.WorkspaceLive.Threat.Components.TextInputComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Threat.Components.TextInputComponent

  @context %{
    title: "Threat Title",
    description: "Threat Description",
    examples: ["Example 1", "Example 2"]
  }

  @assigns %{
    id: "test-id",
    active_field: "test-field",
    current_value: "Initial value",
    context: @context
  }

  test "renders the component with context" do
    html = render_component(TextInputComponent, @assigns)

    assert html =~ @context.title
    assert html =~ @context.description
    assert html =~ "Initial value"
    assert html =~ "Example 1"
    assert html =~ "Example 2"
  end

  test "renders the component without examples" do
    assigns = Map.put(@assigns, :context, Map.put(@context, :examples, []))
    html = render_component(TextInputComponent, assigns)

    assert html =~ @context.title
    assert html =~ @context.description
    refute html =~ "Examples:"
  end
end
