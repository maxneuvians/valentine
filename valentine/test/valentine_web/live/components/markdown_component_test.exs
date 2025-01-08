defmodule ValentineWeb.WorkspaceLive.Components.MarkdownComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.MarkdownComponent

  test "renders properly with a text" do
    html = render_component(&MarkdownComponent.render/1, text: "### It works! :tada:")
    assert html =~ "<h3>It works! 🎉</h3>"
  end

  test "render an empty string if text is nil" do
    html = render_component(&MarkdownComponent.render/1, text: nil)
    assert html == "<div class=\"markdown\">\n  \n</div>"
  end
end
