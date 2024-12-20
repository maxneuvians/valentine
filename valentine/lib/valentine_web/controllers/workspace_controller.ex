defmodule ValentineWeb.WorkspaceController do
  use ValentineWeb, :controller

  alias Valentine.Composer

  def pdf(conn, %{"workspace_id" => workspace_id}) do
    workspace = get_workspace(workspace_id)
    {:ok, pdf} = to_pdf(workspace)

    send_download(
      conn,
      {:binary, Base.decode64!(pdf)},
      content_type: "application/pdf",
      filename: "Threat model for #{workspace.name}.pdf"
    )
  end

  def to_pdf(workspace) do
    [
      content: [get_styles(), "<body>", content(workspace), "</body>"],
      size: :us_letter
    ]
    |> ChromicPDF.Template.source_and_options()
    |> ChromicPDF.print_to_pdf()
  end

  defp content(workspace) do
    ValentineWeb.WorkspaceLive.ThreatModel.Components.ReportComponent.render(%{
      workspace: workspace
    })
    |> Phoenix.HTML.Safe.to_iodata()
  end

  defp get_styles() do
    """
    <style>
    /* Basic reset */
    * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    }

    /* Document structure */
    body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    }

    /* Typography */
    h1, h2, h3, h4, h5, h6 {
    margin: 1.5em 0 0.5em;
    line-height: 1.2;
    }

    h1 { font-size: 2em; }
    h2 { font-size: 1.5em; }
    h3 { font-size: 1.3em; }

    p {
    margin-bottom: 1em;
    }

    /* Links */
    a {
    color: #0066cc;
    text-decoration: none;
    }

    a:hover {
    text-decoration: underline;
    }

    /* Tables */
    table {
    width: 100%;
    border-collapse: collapse;
    margin: 1em 0;
    }

    th, td {
    padding: 8px;
    border: 1px solid #ddd;
    text-align: left;
    }

    th {
    background-color: #f5f5f5;
    }

    tr:nth-child(even) {
    background-color: #f9f9f9;
    }

    /* Images */
    img {
    max-width: 100%;
    height: auto;
    margin: 1em 0;
    display: block;
    }

    .diagram-container {
    max-width: 800px;
    margin: 2em auto;
    }

    .diagram-container img {
    width: 100%;
    border: 1px solid #eee;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    /* Lists */
    ul, ol {
    margin: 1em 0;
    padding-left: 2em;
    }

    li {
    margin-bottom: 0.5em;
    }

    /* Code blocks */
    pre, code {
    font-family: Consolas, Monaco, 'Andale Mono', monospace;
    background: #f5f5f5;
    padding: 0.2em 0.4em;
    border-radius: 3px;
    font-size: 0.9em;
    }

    pre {
    padding: 1em;
    overflow-x: auto;
    margin: 1em 0;
    }

    /* Print styles */
    @media print {
    body {
        max-width: none;
        padding: 2cm;
    }

    img {
        max-width: 100% !important;
        page-break-inside: avoid;
    }

    h1, h2, h3 {
        page-break-after: avoid;
    }

    table {
        page-break-inside: avoid;
    }
    }
    </style>
    """
  end

  def export(conn, %{"workspace_id" => workspace_id}) do
    workspace = get_workspace(workspace_id)
    json = serialize_workspace(workspace)

    send_download(
      conn,
      {:binary, json},
      content_type: "application/json",
      filename: "Workspace_#{workspace.name}.json"
    )
  end

  def export_assumptions(conn, %{"workspace_id" => workspace_id}) do
    workspace = get_workspace(workspace_id)

    assumptions = %{
      name: workspace.name,
      description: "Assumptions for #{workspace.name}",
      assumptions:
        serialize_assumptions(workspace.assumptions)
        |> Enum.map(fn assumption ->
          assumption
          |> Map.delete(:threats)
          |> Map.delete(:mitigations)
        end)
    }

    send_download(
      conn,
      {:binary, Jason.encode!(assumptions)},
      content_type: "application/json",
      filename: "Assumptions_#{workspace.name}_Reference_Pack.json"
    )
  end

  def export_mitigations(conn, %{"workspace_id" => workspace_id}) do
    workspace = get_workspace(workspace_id)

    mitigations = %{
      name: workspace.name,
      description: "Mitigations for #{workspace.name}",
      mitigations:
        serialize_mitigations(workspace.mitigations)
        |> Enum.map(fn mitigation ->
          mitigation
          |> Map.delete(:threats)
          |> Map.delete(:assumptions)
        end)
    }

    send_download(
      conn,
      {:binary, Jason.encode!(mitigations)},
      content_type: "application/json",
      filename: "Mitigations_#{workspace.name}_Reference_Pack.json"
    )
  end

  def export_threats(conn, %{"workspace_id" => workspace_id}) do
    workspace = get_workspace(workspace_id)

    threats = %{
      name: workspace.name,
      description: "Threats for #{workspace.name}",
      threats:
        serialize_threats(workspace.threats)
        |> Enum.map(fn threat ->
          threat
          |> Map.delete(:assumptions)
          |> Map.delete(:mitigations)
        end)
    }

    send_download(
      conn,
      {:binary, Jason.encode!(threats)},
      content_type: "application/json",
      filename: "Threats_#{workspace.name}_Reference_Pack.json"
    )
  end

  defp serialize_workspace(workspace) do
    %{
      workspace: %{
        name: workspace.name,
        assumptions: serialize_assumptions(workspace.assumptions),
        mitigations: serialize_mitigations(workspace.mitigations),
        threats: serialize_threats(workspace.threats)
      }
    }
    |> Jason.encode!()
  end

  defp serialize_assumptions(assumptions) do
    Enum.map(assumptions, fn assumption ->
      %{
        id: assumption.id,
        content: assumption.content,
        comments: assumption.comments,
        tags: assumption.tags,
        threats: Enum.map(assumption.threats, & &1.id),
        mitigations: Enum.map(assumption.mitigations, & &1.id)
      }
    end)
  end

  defp serialize_mitigations(mitigations) do
    Enum.map(mitigations, fn mitigation ->
      %{
        id: mitigation.id,
        content: mitigation.content,
        comments: mitigation.comments,
        status: mitigation.status,
        tags: mitigation.tags,
        threats: Enum.map(mitigation.threats, & &1.id),
        assumptions: Enum.map(mitigation.assumptions, & &1.id)
      }
    end)
  end

  defp serialize_threats(threats) do
    Enum.map(threats, fn threat ->
      %{
        id: threat.id,
        status: threat.status,
        priority: threat.priority,
        stride: threat.stride,
        comments: threat.comments,
        threat_source: threat.threat_source,
        prerequisites: threat.prerequisites,
        threat_action: threat.threat_action,
        threat_impact: threat.threat_impact,
        impacted_goal: threat.impacted_goal,
        impacted_assets: threat.impacted_assets,
        tags: threat.tags,
        assumptions: Enum.map(threat.assumptions, & &1.id),
        mitigations: Enum.map(threat.mitigations, & &1.id)
      }
    end)
  end

  defp get_workspace(id) do
    Composer.get_workspace!(id, [
      :application_information,
      :architecture,
      :data_flow_diagram,
      mitigations: [:assumptions, :threats],
      threats: [:assumptions, :mitigations],
      assumptions: [:threats, :mitigations]
    ])
  end
end
