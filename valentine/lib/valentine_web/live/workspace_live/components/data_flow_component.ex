defmodule ValentineWeb.WorkspaceLive.Components.DataFlowComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def render(assigns) do
    ~H"""
    <div>
      <.box>
        <div id="cytoscape-container" class="Box-body">
          <div id="cy" tabindex="0"></div>
        </div>
      </.box>
    </div>
    """
  end
end
