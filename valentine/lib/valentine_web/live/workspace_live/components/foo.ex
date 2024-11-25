defmodule ValentineWeb.WorkspaceLive.Components.FooComponent do
  use ValentineWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div class="Box p-3 mt-3">
        <div class="BtnGroup">
          <button type="button" class="btn BtnGroup-item" phx-click="add_node">
            Add Node
          </button>
        </div>
      </div>
      <div class="Box color-bg-default">
        <div id="cytoscape-container" class="Box-body" style="height: 600px;">
          <div id="cy" style="width: 100%; height: 100%;"></div>
        </div>
      </div>
    </div>
    """
  end
end
