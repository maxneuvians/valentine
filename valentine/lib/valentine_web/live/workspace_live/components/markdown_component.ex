defmodule ValentineWeb.WorkspaceLive.Components.MarkdownComponent do
  use ValentineWeb, :live_component

  def render(assigns) do
    text = if assigns.text == nil, do: "", else: assigns.text

    markdown_html =
      String.trim(text)
      |> MDEx.to_html!(extension: [shortcodes: true])
      |> Phoenix.HTML.raw()

    assigns = assign(assigns, :markdown, markdown_html)

    ~H"""
    <div>
      <%= @markdown %>
    </div>
    """
  end
end
