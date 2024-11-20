defmodule ValentineWeb.WorkspaceLive.Components.AssumptionComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def render(assigns) do
    if assigns.assumption == nil do
      ""
    else
      ~H"""
      <div style="width:100%">
        <div class="clearfix mb-3">
          <div class="float-left">
            <h3>Assumption <%= @assumption.numeric_id %></h3>
          </div>
          <div class="float-right">
            <.button
              is_icon_button
              aria-label="Edit"
              phx-click={
                JS.patch(~p"/workspaces/#{@assumption.workspace_id}/assumptions/#{@assumption.id}/edit")
              }
              id={"edit-assumption-#{@assumption.id}"}
            >
              <.octicon name="pencil-16" />
            </.button>
            <.button
              is_icon_button
              is_danger
              aria-label="Delete"
              phx-click={JS.push("delete", value: %{id: @assumption.id})}
              data-confirm="Are you sure?"
              id={"delete-assumption-#{@assumption.id}"}
            >
              <.octicon name="trash-16" />
            </.button>
          </div>
        </div>
        <.styled_html>
          <p>
            <%= @assumption.content %>
          </p>
        </.styled_html>
      </div>
      """
    end
  end
end
