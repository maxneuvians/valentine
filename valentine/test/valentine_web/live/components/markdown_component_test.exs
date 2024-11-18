defmodule ValentineWeb.WorkspaceLive.Components.MarkdownComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.MarkdownComponent

  test "renders properly with a placeholder" do
    assigns = %{
      text: "### It works! :tada:"
    }

    html = render_component(MarkdownComponent, assigns)
    assert html =~ "<h3>It works! 🎉</h3>"
  end
end
