defmodule ValentineWeb.WorkspaceLive.Components.WorkspaceComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  @impl true
  def render(assigns) do
    ~H"""
    <div style="width:100%">
      <div class="clearfix">
        <div class="float-left">
          <.link navigate={~p"/workspaces/#{@workspace}"}><%= @workspace.name %></.link>
        </div>
        <div class="float-right">
          <.button
            is_icon_button
            aria-label="Edit"
            phx-click={JS.patch(~p"/workspaces/#{@workspace.id}/edit")}
            id={"edit-workspace-#{@workspace.id}"}
          >
            <.octicon name="pencil-16" />
          </.button>
          <.button
            is_icon_button
            is_danger
            aria-label="Delete"
            phx-click={JS.push("delete", value: %{id: @workspace.id})}
            data-confirm="Are you sure?"
            id={"delete-workspace-#{@workspace.id}"}
          >
            <.octicon name="trash-16" />
          </.button>
        </div>
      </div>
    </div>
    """
  end
end
