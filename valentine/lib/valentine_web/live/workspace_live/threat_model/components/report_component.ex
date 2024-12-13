defmodule ValentineWeb.WorkspaceLive.ThreatModel.Components.ReportComponent do
  use Phoenix.Component
  use PrimerLive

  def render(assigns) do
    ~H"""
    <.styled_html>
      <h3>Table of Contents</h3>

      <ol>
        <li><a href="#application_information">Application Information</a></li>
        <li><a href="#architecture">Architecture</a></li>
        <li><a href="#data_flow_diagram">Data Flow</a></li>
        <li><a href="#assumptions">Assumptions</a></li>
        <li><a href="#threats">Threats</a></li>
        <li><a href="#mitigations">Mitigations</a></li>
        <li><a href="#impacted_assets">Impacted Assets</a></li>
      </ol>

      <h3 id="application_information">1. Application Information</h3>
      <%= optional_content(@workspace.application_information) |> Phoenix.HTML.raw() %>

      <h3 id="architecture">2. Architecture</h3>
      <%= optional_content(@workspace.architecture) |> Phoenix.HTML.raw() %>

      <h3 id="data_flow_diagram">3. Data Flow</h3>
      <.box :if={@workspace.data_flow_diagram && @workspace.data_flow_diagram.raw_image} id="data-flow-diagram-container">
        <img src={@workspace.data_flow_diagram.raw_image} alt="Data flow diagram" />
      </.box>
      <h3 id="assumptions">4. Assumptions</h3>
      <table class="report-table">
        <thead>
          <tr>
            <th>Assumption ID</th>
            <th>Assumption</th>
            <th>Linked Threats</th>
            <th>Linked Mitigations</th>
            <th>Comments</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={assumption <- @workspace.assumptions} id={"A-#{assumption.numeric_id}"}>
            <td>A-<%= assumption.numeric_id %></td>
            <td><%= assumption.content %></td>
            <td>
              <ul>
                <li :for={threat <- assumption.threats}>
                  <a href={"#T-#{threat.numeric_id}"}>T-<%= threat.numeric_id %></a>
                </li>
              </ul>
            </td>
            <td>
              <ul>
                <li :for={mitigation <- assumption.mitigations}>
                  <a href={"#M-#{mitigation.numeric_id}"}>M-<%= mitigation.numeric_id %></a>
                </li>
              </ul>
            </td>
            <td>
              <%= to_markdown(assumption.comments) %>
            </td>
          </tr>
        </tbody>
      </table>

      <h3 id="threats">5. Threats</h3>
      <table class="report-table">
        <thead>
          <tr>
            <th>Threat ID</th>
            <th>Threat</th>
            <th>Assumptions</th>
            <th>Mitigations</th>
            <th>Status</th>
            <th>Priority</th>
            <th>STRIDE</th>
            <th>Comments</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={threat <- @workspace.threats} id={"T-#{threat.numeric_id}"}>
            <td>T-<%= threat.numeric_id %></td>
            <td></td>
            <td>
              <ul>
                <li :for={assumption <- threat.assumptions}>
                  <a href={"#A-#{assumption.numeric_id}"}>A-<%= assumption.numeric_id %></a>
                </li>
              </ul>
            </td>
            <td>
              <ul>
                <li :for={mitigation <- threat.mitigations}>
                  <a href={"#M-#{mitigation.numeric_id}"}>M-<%= mitigation.numeric_id %></a>
                </li>
              </ul>
            </td>
            <td><%= Phoenix.Naming.humanize(threat.status) %></td>
            <td><%= Phoenix.Naming.humanize(threat.priority) %></td>
            <td><%= stride_to_letter(threat.stride) %></td>
            <td>
              <%= to_markdown(threat.comments) %>
            </td>
          </tr>
        </tbody>
      </table>

      <h3 id="mitigations">6. Mitigations</h3>
      <table class="report-table">
        <thead>
          <tr>
            <th>Mitigation ID</th>
            <th>Mitigation</th>
            <th>Threats Mitigating</th>
            <th>Assumptions</th>
            <th>Comments</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={mitigation <- @workspace.mitigations} id={"M-#{mitigation.numeric_id}"}>
            <td>M-<%= mitigation.numeric_id %></td>
            <td><%= mitigation.content %></td>
            <td>
              <ul>
                <li :for={threat <- mitigation.threats}>
                  <a href={"#T-#{threat.numeric_id}"}>T-<%= threat.numeric_id %></a>
                </li>
              </ul>
            </td>
            <td>
              <ul>
                <li :for={assumption <- mitigation.assumptions}>
                  <a href={"#A-#{assumption.numeric_id}"}>A-<%= assumption.numeric_id %></a>
                </li>
              </ul>
            </td>
            <td>
              <%= to_markdown(mitigation.comments) %>
            </td>
          </tr>
        </tbody>
      </table>

      <h3 id="impacted_assets">7. Impacted Assets</h3>
      <table class="report-table">
        <thead>
          <tr>
            <th>Asset ID</th>
            <th>Asset</th>
            <th>Related Threats</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{{asset, t_ids}, i} <- get_assets(@workspace.threats)} id={"AS-#{i + 1}"}>
            <td>AS-<%= i + 1 %></td>
            <td><%= asset %></td>
            <td>
              <ul>
                <li :for={threat_id <- t_ids}>
                  <a href={"#T-#{threat_id}"}>T-<%= threat_id %></a>
                </li>
              </ul>
            </td>
          </tr>
        </tbody>
      </table>
    </.styled_html>
    """
  end

  defp get_assets(threats) do
    threats
    |> Enum.filter(&(&1.impacted_assets != [] && &1.impacted_assets != nil))
    |> Enum.reduce(%{}, fn t, acc ->
      Enum.reduce(t.impacted_assets, acc, fn asset, a ->
        Map.update(a, asset, [t.numeric_id], &(&1 ++ [t.numeric_id]))
      end)
    end)
    |> Enum.with_index()
  end

  defp optional_content(nil), do: "<i>Not set</i>"
  defp optional_content(model), do: model.content

  defp stride_to_letter(nil), do: ""

  defp stride_to_letter(data) do
    data
    |> Enum.map(&Atom.to_string/1)
    |> Enum.map(&String.upcase/1)
    |> Enum.map(&String.first/1)
    |> Enum.join()
  end

  defp to_markdown(nil), do: ""

  defp to_markdown(text) do
    text
    |> String.trim()
    |> MDEx.to_html!(extension: [shortcodes: true])
    |> Phoenix.HTML.raw()
  end
end
