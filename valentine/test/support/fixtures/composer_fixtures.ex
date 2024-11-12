defmodule Valentine.ComposerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Valentine.Composer` context.
  """

  @doc """
  Generate a workspace.
  """
  def workspace_fixture(attrs \\ %{}) do
    {:ok, workspace} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Valentine.Composer.create_workspace()

    workspace
  end

  @doc """
  Generate a threat.
  """
  def threat_fixture(attrs \\ %{}) do

    workspace = workspace_fixture()

    {:ok, threat} =
      attrs
      |> Enum.into(%{
        display_order: 42,
        impacted_assets: ["option1", "option2"],
        impacted_goal: ["option1", "option2"],
        metadata: %{},
        numeric_id: 42,
        prerequisites: "some prerequisites",
        threat_action: "some threat_action",
        threat_impact: "some threat_impact",
        threat_source: "some threat_source",
        tags: ["tag1", "tag2"],
        workspace_id: workspace.id
        })
      |> Valentine.Composer.create_threat()

    threat
  end
end
