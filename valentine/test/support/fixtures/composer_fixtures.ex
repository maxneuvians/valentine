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
    {:ok, threat} =
      attrs
      |> Enum.into(%{
        action: "some action",
        asset: "some asset",
        goal: "some goal",
        impact: "some impact",
        prerequisite: "some prerequisite",
        source: "some source"
      })
      |> Valentine.Composer.create_threat()

    threat
  end
end
