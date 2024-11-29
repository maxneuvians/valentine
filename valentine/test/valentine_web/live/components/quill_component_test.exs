defmodule ValentineWeb.WorkspaceLive.Components.QuillComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Components.QuillComponent

  test "renders properly with id=\"quill-editor\"" do
    html = render_component(QuillComponent, %{:content => "Hello, World!"})
    assert html =~ "id=\"quill-editor\""
    assert html =~ "Hello, World!"
  end

  describe "handle_event/2" do
    test "quill-change" do
      {:noreply, socket} = QuillComponent.handle_event("quill-change", %{"delta" => "delta"}, %{})
      assert send(self(), {:quill_change, "delta"}) == {:quill_change, "delta"}
      assert socket == %{}
    end

    test "quill-save" do
      {:noreply, socket} =
        QuillComponent.handle_event("quill-save", %{"content" => "content"}, %{})

      assert send(self(), {:quill_save, "content"}) == {:quill_save, "content"}
      assert socket == %{}
    end
  end
end
