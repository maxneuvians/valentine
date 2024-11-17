defmodule ValentineWeb.WorkspaceLive.Components.ThreatComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def render(assigns) do
    if assigns.threat == nil do
      ""
    else
      ~H"""
      <div>
        <div class="clearfix mb-3">
          <div class="float-left">
            <h3>Threat <%= @threat.numeric_id %></h3>
          </div>
          <div class="float-right">
            <.button
              is_icon_button
              aria-label="Edit"
              navigate={~p"/workspaces/#{@threat.workspace_id}/threats/#{@threat.id}"}
            >
              <.octicon name="pencil-16" />
            </.button>
            <.button
              is_icon_button
              aria-label="Copy"
              navigate={~p"/workspaces/#{@threat.workspace_id}/threats/#{@threat.id}"}
            >
              <.octicon name="duplicate-16" />
            </.button>
            <.button
              is_icon_button
              is_danger
              aria-label="Delete"
              phx-click={JS.push("delete", value: %{id: @threat.id}) |> hide("#threats-#{@threat.id}")}
              data-confirm="Are you sure?"
            >
              <.octicon name="trash-16" />
            </.button>
          </div>
        </div>
        <%= ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpers.a_or_an(
          @threat.threat_source,
          true
        ) %>
        <%= @threat.threat_source %>
        <%= @threat.prerequisites %> can <%= @threat.threat_action %> which leads to <%= @threat.threat_impact %>,
        <%= if @threat.impacted_goal && @threat.impacted_goal != [] do %>
          result in reduced <%= ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpers.join_list(
            @threat.impacted_goal
          ) %>
        <% end %>
        which leads to negatively impacting <%= ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpers.join_list(
          @threat.impacted_assets
        ) %> .
      </div>
      """
    end
  end
end
