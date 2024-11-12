defmodule Valentine.ComposerTest do
  use Valentine.DataCase

  alias Valentine.Composer

  describe "workspaces" do
    alias Valentine.Composer.Workspace

    import Valentine.ComposerFixtures

    @invalid_attrs %{name: nil}

    test "list_workspaces/0 returns all workspaces" do
      workspace = workspace_fixture()
      assert Composer.list_workspaces() == [workspace]
    end

    test "get_workspace!/1 returns the workspace with given id" do
      workspace = workspace_fixture()
      assert Composer.get_workspace!(workspace.id) == workspace
    end

    test "create_workspace/1 with valid data creates a workspace" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Workspace{} = workspace} = Composer.create_workspace(valid_attrs)
      assert workspace.name == "some name"
    end

    test "create_workspace/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Composer.create_workspace(@invalid_attrs)
    end

    test "update_workspace/2 with valid data updates the workspace" do
      workspace = workspace_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Workspace{} = workspace} = Composer.update_workspace(workspace, update_attrs)
      assert workspace.name == "some updated name"
    end

    test "update_workspace/2 with invalid data returns error changeset" do
      workspace = workspace_fixture()
      assert {:error, %Ecto.Changeset{}} = Composer.update_workspace(workspace, @invalid_attrs)
      assert workspace == Composer.get_workspace!(workspace.id)
    end

    test "delete_workspace/1 deletes the workspace" do
      workspace = workspace_fixture()
      assert {:ok, %Workspace{}} = Composer.delete_workspace(workspace)
      assert_raise Ecto.NoResultsError, fn -> Composer.get_workspace!(workspace.id) end
    end

    test "change_workspace/1 returns a workspace changeset" do
      workspace = workspace_fixture()
      assert %Ecto.Changeset{} = Composer.change_workspace(workspace)
    end
  end

  describe "threats" do
    alias Valentine.Composer.Threat

    import Valentine.ComposerFixtures

    @invalid_attrs %{metadata: nil, uuid: nil, threat_source: nil, prerequisites: nil, threat_action: nil, threat_impact: nil, impacted_goal: nil, impacted_assets: nil}

    test "list_threats/0 returns all threats" do
      threat = threat_fixture()
      assert Composer.list_threats() == [threat]
    end

    test "get_threat!/1 returns the threat with given id" do
      threat = threat_fixture()
      assert Composer.get_threat!(threat.id) == threat
    end

    test "create_threat/1 with valid data creates a threat" do
      workspace = workspace_fixture()
      valid_attrs = %{workspace_id: workspace.id, metadata: %{}, threat_source: "some threat_source", prerequisites: "some prerequisites", threat_action: "some threat_action", threat_impact: "some threat_impact", impacted_goal: ["option1", "option2"], impacted_assets: ["option1", "option2"], tags: ["tag1", "tag2"]}

      assert {:ok, %Threat{} = threat} = Composer.create_threat(valid_attrs)
      assert threat.metadata == %{}
      assert threat.threat_source == "some threat_source"
      assert threat.prerequisites == "some prerequisites"
      assert threat.threat_action == "some threat_action"
      assert threat.threat_impact == "some threat_impact"
      assert threat.impacted_goal == ["option1", "option2"]
      assert threat.impacted_assets == ["option1", "option2"]
    end

    test "create_threat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Composer.create_threat(@invalid_attrs)
    end

    test "update_threat/2 with valid data updates the threat" do
      threat = threat_fixture()
      update_attrs = %{metadata: %{}, threat_source: "some updated threat_source", prerequisites: "some updated prerequisites", threat_action: "some updated threat_action", threat_impact: "some updated threat_impact", impacted_goal: ["option1"], impacted_assets: ["option1"], tags: ["tag1", "tag2"]}

      assert {:ok, %Threat{} = threat} = Composer.update_threat(threat, update_attrs)
      assert threat.metadata == %{}
      assert threat.threat_source == "some updated threat_source"
      assert threat.prerequisites == "some updated prerequisites"
      assert threat.threat_action == "some updated threat_action"
      assert threat.threat_impact == "some updated threat_impact"
      assert threat.impacted_goal == ["option1"]
      assert threat.impacted_assets == ["option1"]
    end

    test "update_threat/2 with invalid data returns error changeset" do
      threat = threat_fixture()
      assert {:error, %Ecto.Changeset{}} = Composer.update_threat(threat, @invalid_attrs)
      assert threat == Composer.get_threat!(threat.id)
    end

    test "delete_threat/1 deletes the threat" do
      threat = threat_fixture()
      assert {:ok, %Threat{}} = Composer.delete_threat(threat)
      assert_raise Ecto.NoResultsError, fn -> Composer.get_threat!(threat.id) end
    end

    test "change_threat/1 returns a threat changeset" do
      threat = threat_fixture()
      assert %Ecto.Changeset{} = Composer.change_threat(threat)
    end
  end
end
