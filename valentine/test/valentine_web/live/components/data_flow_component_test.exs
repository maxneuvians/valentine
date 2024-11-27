defmodule ValentineWeb.WorkspaceLive.Components.DataFlowComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.DataFlowComponent

  test "renders properly with id=\"cy\"" do
    html = render_component(DataFlowComponent, %{})
    assert html =~ "id=\"cy\""
  end
end
