defmodule ValentineWeb.WorkspaceLive.Components.DataFlowComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def render(assigns) do
    ~H"""
    <div>
      <div class="d-flex mb-2">
        <div class="d-flex flex-column mr-4">
          <span class="text-small text-bold mb-1">&nbsp;</span>
          <.button is_primary class="mb-2" id="quill-save-btn">
            <span>Save</span>
          </.button>
        </div>
        <div class="d-flex flex-column mr-2">
          <span class="text-small text-bold mb-1">Entities</span>
          <.button_group class="mr-2">
            <.button
              is_icon_button
              aria-label="Add Actor"
              title="Add actor"
              phx-click="add_node"
              phx-value-type="actor"
            >
              <.octicon name="person-24" />
            </.button>
            <.button
              is_icon_button
              aria-label="Add Process"
              title="Add process"
              phx-click="add_node"
              phx-value-type="process"
            >
              <.octicon name="circle-24" />
            </.button>
            <.button
              is_icon_button
              aria-label="Add Datastore"
              title="Add datastore"
              phx-click="add_node"
              phx-value-type="datastore"
            >
              <.octicon name="stack-24" />
            </.button>
          </.button_group>
        </div>
        <div class="d-flex flex-column mr-2">
          <span class="text-small text-bold mb-1">Boundaries</span>
          <.button_group class="mr-2">
            <.button
              is_icon_button
              aria-label="Add Boundary"
              title="Add boundary"
              phx-click="group_nodes"
            >
              <.octicon name="fold-up-24" />
            </.button>
            <.button
              is_icon_button
              aria-label="Extend Boundary"
              title="Extend boundary"
              phx-click="merge_group"
            >
              <.octicon name="unfold-24" />
            </.button>
            <.button
              is_icon_button
              aria-label="Remove Boundary"
              title="Remove boundary"
              phx-click="remove_group"
            >
              <.octicon name="fold-24" />
            </.button>
          </.button_group>
        </div>
        <div class="d-flex flex-column mr-2">
          <span class="text-small text-bold mb-1">View options</span>
          <.button_group class="mr-2">
            <.button is_icon_button aria-label="Fit View" title="Fit view" phx-click="fit_view">
              <.octicon name="project-template-24" />
            </.button>
            <.button is_icon_button aria-label="Zoom in" title="Zoom in" phx-click="zoom_in">
              <.octicon name="plus-24" />
            </.button>
            <.button is_icon_button aria-label="Zoom out" title="Zoom out" phx-click="zoom_out">
              <.octicon name="horizontal-rule-24" />
            </.button>
          </.button_group>
        </div>
        <div class="d-flex flex-column mr-2">
          <span class="text-small text-bold mb-1">Destructive actions</span>
          <.button_group class="mr-2">
            <.button
              is_icon_button
              aria-label="Remove selected elements"
              title="Remove selected elements"
              phx-click="remove_elements"
            >
              <.octicon name="x-24" />
            </.button>
            <.button
              is_icon_button
              aria-label="Clear entire diagram"
              title="Clear entire diagram"
              phx-click="clear_dfd"
              is_danger
            >
              <.octicon name="trash-24" />
            </.button>
          </.button_group>
        </div>
      </div>
      <.box>
        <div id="cytoscape-container" class="Box-body">
          <div id="cy" tabindex="0"></div>
        </div>
      </.box>
    </div>
    """
  end
end
