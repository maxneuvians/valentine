defmodule ValentineWeb.WorkspaceLive.Components.DataFlowComponent do
  use ValentineWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div class="BtnGroup mb-2">
        <button type="button" class="btn BtnGroup-item" phx-click="add_node" phx-value-type="actor">
          Add Actor
        </button>
        <button type="button" class="btn BtnGroup-item" phx-click="add_node" phx-value-type="process">
          Add Process
        </button>
        <button
          type="button"
          class="btn BtnGroup-item"
          phx-click="add_node"
          phx-value-type="datastore"
        >
          Add Datastore
        </button>

        <button type="button" class="btn BtnGroup-item" phx-click="fit_view">
          Fit View
        </button>
      </div>
      <div class="Box color-bg-default">
        <div id="cytoscape-container" class="Box-body" style="height: 400px;">
          <div id="cy" style="width: 100%; height: 100%;" tabindex="0"></div>
        </div>
      </div>
    </div>
    """
  end
end
