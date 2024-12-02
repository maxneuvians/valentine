defmodule ValentineWeb.WorkspaceLive.Components.DataFlowComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def render(assigns) do
    ~H"""
    <div>
      <div class="d-flex mb-2">
        <.button_group class="mr-2">
          <.button is_icon_button aria-label="Add Actor" phx-click="add_node" phx-value-type="actor">
            <.octicon name="person-24" />
          </.button>
          <.button
            is_icon_button
            aria-label="Add Process"
            phx-click="add_node"
            phx-value-type="process"
          >
            <.octicon name="circle-24" />
          </.button>
          <.button
            is_icon_button
            aria-label="Add Datastore"
            phx-click="add_node"
            phx-value-type="datastore"
          >
            <.octicon name="stack-24" />
          </.button>
        </.button_group>
        <.button_group class="mr-2">
          <.button is_icon_button aria-label="Add Boundary" phx-click="group_nodes">
            <.octicon name="fold-up-24" />
          </.button>
          <.button is_icon_button aria-label="Extend Boundary" phx-click="merge_group">
            <.octicon name="unfold-24" />
          </.button>
          <.button is_icon_button aria-label="Remove Boundary" phx-click="remove_group">
            <.octicon name="fold-24" />
          </.button>
        </.button_group>
        <.button_group class="mr-2">
          <.button is_icon_button aria-label="Fit View" phx-click="fit_view">
            <.octicon name="project-template-24" />
          </.button>
        </.button_group>
        <.button_group class="mr-2">
          <.button is_icon_button aria-label="Remove elements" phx-click="remove_elements">
            <.octicon name="x-24" />
          </.button>
          <.button is_icon_button aria-label="Clear diagram" phx-click="clear_dfd">
            <.octicon name="trash-24" />
          </.button>
        </.button_group>
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
