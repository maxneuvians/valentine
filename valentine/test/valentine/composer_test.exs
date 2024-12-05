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

    @invalid_attrs %{
      uuid: nil,
      status: nil,
      priority: nil,
      stride: nil,
      comments: nil,
      threat_source: nil,
      prerequisites: nil,
      threat_action: nil,
      threat_impact: nil,
      impacted_goal: nil,
      impacted_assets: nil
    }

    test "list_threats/0 returns all threats" do
      threat = threat_fixture()
      assert Composer.list_threats() == [threat]
    end

    test "list_threats_by_workspace/2 returns all threats for a workspace" do
      threat = threat_fixture()
      assert Composer.list_threats_by_workspace(threat.workspace_id) == [threat]
    end

    test "list_threats_by_workspace/2 returns all threats for a workspace adnd not other workspaces" do
      assert Composer.list_threats_by_workspace("00000000-0000-0000-0000-000000000000") == []
    end

    test "get_threat!/1 returns the threat with given id" do
      threat = threat_fixture()
      assert Composer.get_threat!(threat.id) == threat
    end

    test "create_threat/1 with valid data creates a threat" do
      workspace = workspace_fixture()

      valid_attrs = %{
        workspace_id: workspace.id,
        status: :identified,
        priority: :high,
        stride: [:spoofing],
        comments: "some comments",
        threat_source: "some threat_source",
        prerequisites: "some prerequisites",
        threat_action: "some threat_action",
        threat_impact: "some threat_impact",
        impacted_goal: ["option1", "option2"],
        impacted_assets: ["option1", "option2"],
        tags: ["tag1", "tag2"]
      }

      assert {:ok, %Threat{} = threat} = Composer.create_threat(valid_attrs)
      assert threat.status == :identified
      assert threat.priority == :high
      assert threat.stride == [:spoofing]
      assert threat.comments == "some comments"
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

      update_attrs = %{
        status: :resolved,
        priority: :low,
        stride: [:tampering],
        comments: "some updated comments",
        threat_source: "some updated threat_source",
        prerequisites: "some updated prerequisites",
        threat_action: "some updated threat_action",
        threat_impact: "some updated threat_impact",
        impacted_goal: ["option1"],
        impacted_assets: ["option1"],
        tags: ["tag1", "tag2"]
      }

      assert {:ok, %Threat{} = threat} = Composer.update_threat(threat, update_attrs)
      assert threat.status == :resolved
      assert threat.priority == :low
      assert threat.stride == [:tampering]
      assert threat.comments == "some updated comments"
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

    test "add_assumption_to_threat/2 adds an assumption to a threat" do
      threat = threat_fixture()
      assumption = assumption_fixture()

      assert {:ok, %Threat{} = threat} = Composer.add_assumption_to_threat(threat, assumption)
      assert threat.assumptions == [assumption]
    end

    test "add_assumption_to_threat/2 adds an assumption to existing threat assumptions" do
      threat = threat_fixture()
      assumption = assumption_fixture()

      Composer.add_assumption_to_threat(threat, assumption)

      assumption2 = assumption_fixture()

      assert {:ok, %Threat{} = threat} = Composer.add_assumption_to_threat(threat, assumption2)
      assert threat.assumptions == [assumption, assumption2]
    end

    test "remove_assumption_from_threat/2 removes an assumption from a threat" do
      threat = threat_fixture()
      assumption = assumption_fixture()

      {:ok, %Threat{} = threat} = Composer.add_assumption_to_threat(threat, assumption)

      assert threat.assumptions == [assumption]

      {:ok, %Threat{} = threat} = Composer.remove_assumption_from_threat(threat, assumption)

      assert threat.assumptions == []
    end

    test "add_mitigation_to_threat/2 adds an mitigation to a threat" do
      threat = threat_fixture()
      mitigation = mitigation_fixture()

      assert {:ok, %Threat{} = threat} = Composer.add_mitigation_to_threat(threat, mitigation)
      assert threat.mitigations == [mitigation]
    end

    test "add_mitigation_to_threat/2 adds an mitigation to existing threat mitigations" do
      threat = threat_fixture()
      mitigation = mitigation_fixture()

      Composer.add_mitigation_to_threat(threat, mitigation)

      mitigation2 = mitigation_fixture()

      assert {:ok, %Threat{} = threat} = Composer.add_mitigation_to_threat(threat, mitigation2)
      assert threat.mitigations == [mitigation, mitigation2]
    end

    test "remove_mitigation_from_threat/2 removes an mitigation from a threat" do
      threat = threat_fixture()
      mitigation = mitigation_fixture()

      {:ok, %Threat{} = threat} = Composer.add_mitigation_to_threat(threat, mitigation)

      assert threat.mitigations == [mitigation]

      {:ok, %Threat{} = threat} = Composer.remove_mitigation_from_threat(threat, mitigation)

      assert threat.mitigations == []
    end
  end

  describe "assumptions" do
    alias Valentine.Composer.Assumption

    import Valentine.ComposerFixtures

    @invalid_attrs %{comments: nil, content: nil, tags: nil}

    test "list_assumptions/0 returns all assumptions" do
      assumption = assumption_fixture()
      assert Composer.list_assumptions() == [assumption]
    end

    test "get_assumption!/1 returns the assumption with given id" do
      assumption = assumption_fixture()
      assert Composer.get_assumption!(assumption.id) == assumption
    end

    test "create_assumption/1 with valid data creates a assumption" do
      workspace = workspace_fixture()

      valid_attrs = %{
        comments: "some comments",
        content: "some content",
        tags: ["option1", "option2"],
        workspace_id: workspace.id
      }

      assert {:ok, %Assumption{} = assumption} = Composer.create_assumption(valid_attrs)
      assert assumption.comments == "some comments"
      assert assumption.content == "some content"
      assert assumption.tags == ["option1", "option2"]
    end

    test "create_assumption/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Composer.create_assumption(@invalid_attrs)
    end

    test "update_assumption/2 with valid data updates the assumption" do
      assumption = assumption_fixture()

      update_attrs = %{
        comments: "some updated comments",
        content: "some updated content",
        tags: ["option1"]
      }

      assert {:ok, %Assumption{} = assumption} =
               Composer.update_assumption(assumption, update_attrs)

      assert assumption.comments == "some updated comments"
      assert assumption.content == "some updated content"
      assert assumption.tags == ["option1"]
    end

    test "update_assumption/2 with invalid data returns error changeset" do
      assumption = assumption_fixture()
      assert {:error, %Ecto.Changeset{}} = Composer.update_assumption(assumption, @invalid_attrs)
      assert assumption == Composer.get_assumption!(assumption.id)
    end

    test "delete_assumption/1 deletes the assumption" do
      assumption = assumption_fixture()
      assert {:ok, %Assumption{}} = Composer.delete_assumption(assumption)
      assert_raise Ecto.NoResultsError, fn -> Composer.get_assumption!(assumption.id) end
    end

    test "change_assumption/1 returns a assumption changeset" do
      assumption = assumption_fixture()
      assert %Ecto.Changeset{} = Composer.change_assumption(assumption)
    end

    test "add_mitigation_to_assumption/2 adds an mitigation to a assumption" do
      assumption = assumption_fixture()
      mitigation = mitigation_fixture()

      assert {:ok, %Assumption{} = assumption} =
               Composer.add_mitigation_to_assumption(assumption, mitigation)

      assert assumption.mitigations == [mitigation]
    end

    test "add_mitigation_to_assumption/2 adds an mitigation to existing assumption mitigations" do
      assumption = assumption_fixture()
      mitigation = mitigation_fixture()

      Composer.add_mitigation_to_assumption(assumption, mitigation)

      mitigation2 = mitigation_fixture()

      assert {:ok, %Assumption{} = assumption} =
               Composer.add_mitigation_to_assumption(assumption, mitigation2)

      assert assumption.mitigations == [mitigation, mitigation2]
    end

    test "remove_mitigation_from_assumption/2 removes an mitigation from a assumption" do
      assumption = assumption_fixture()
      mitigation = mitigation_fixture()

      {:ok, %Assumption{} = assumption} =
        Composer.add_mitigation_to_assumption(assumption, mitigation)

      assert assumption.mitigations == [mitigation]

      {:ok, %Assumption{} = assumption} =
        Composer.remove_mitigation_from_assumption(assumption, mitigation)

      assert assumption.mitigations == []
    end
  end

  describe "mitigations" do
    alias Valentine.Composer.Mitigation

    import Valentine.ComposerFixtures

    @invalid_attrs %{comments: nil, content: nil, status: nil, tags: nil}

    test "list_mitigations/0 returns all mitigations" do
      mitigation = mitigation_fixture()
      assert Composer.list_mitigations() == [mitigation]
    end

    test "get_mitigation!/1 returns the mitigation with given id" do
      mitigation = mitigation_fixture()
      assert Composer.get_mitigation!(mitigation.id) == mitigation
    end

    test "create_mitigation/1 with valid data creates a mitigation" do
      workspace = workspace_fixture()

      valid_attrs = %{
        comments: "some comments",
        content: "some content",
        status: :identified,
        tags: ["option1", "option2"],
        workspace_id: workspace.id
      }

      assert {:ok, %Mitigation{} = mitigation} = Composer.create_mitigation(valid_attrs)
      assert mitigation.comments == "some comments"
      assert mitigation.content == "some content"
      assert mitigation.tags == ["option1", "option2"]
    end

    test "create_mitigation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Composer.create_mitigation(@invalid_attrs)
    end

    test "update_mitigation/2 with valid data updates the mitigation" do
      mitigation = mitigation_fixture()

      update_attrs = %{
        comments: "some updated comments",
        content: "some updated content",
        status: :resolved,
        tags: ["option1"]
      }

      assert {:ok, %Mitigation{} = mitigation} =
               Composer.update_mitigation(mitigation, update_attrs)

      assert mitigation.comments == "some updated comments"
      assert mitigation.content == "some updated content"
      assert mitigation.status == :resolved
      assert mitigation.tags == ["option1"]
    end

    test "update_mitigation/2 with invalid data returns error changeset" do
      mitigation = mitigation_fixture()
      assert {:error, %Ecto.Changeset{}} = Composer.update_mitigation(mitigation, @invalid_attrs)
      assert mitigation == Composer.get_mitigation!(mitigation.id)
    end

    test "delete_mitigation/1 deletes the mitigation" do
      mitigation = mitigation_fixture()
      assert {:ok, %Mitigation{}} = Composer.delete_mitigation(mitigation)
      assert_raise Ecto.NoResultsError, fn -> Composer.get_mitigation!(mitigation.id) end
    end

    test "change_mitigation/1 returns a mitigation changeset" do
      mitigation = mitigation_fixture()
      assert %Ecto.Changeset{} = Composer.change_mitigation(mitigation)
    end

    test "add_assumption_to_mitigation/2 adds an assumption to a mitigation" do
      mitigation = mitigation_fixture()
      assumption = assumption_fixture()

      assert {:ok, %Mitigation{} = mitigation} =
               Composer.add_assumption_to_mitigation(mitigation, assumption)

      assert mitigation.assumptions == [assumption]
    end

    test "add_assumption_to_mitigation/2 adds an assumption to existing mitigation assumptions" do
      mitigation = mitigation_fixture()
      assumption = assumption_fixture()

      Composer.add_assumption_to_mitigation(mitigation, assumption)

      assumption2 = assumption_fixture()

      assert {:ok, %Mitigation{} = mitigation} =
               Composer.add_assumption_to_mitigation(mitigation, assumption2)

      assert mitigation.assumptions == [assumption, assumption2]
    end

    test "remove_assumption_from_mitigation/2 removes an assumption from a mitigation" do
      mitigation = mitigation_fixture()
      assumption = assumption_fixture()

      {:ok, %Mitigation{} = mitigation} =
        Composer.add_assumption_to_mitigation(mitigation, assumption)

      assert mitigation.assumptions == [assumption]

      {:ok, %Mitigation{} = mitigation} =
        Composer.remove_assumption_from_mitigation(mitigation, assumption)

      assert mitigation.assumptions == []
    end
  end

  describe "application_informations" do
    alias Valentine.Composer.ApplicationInformation

    import Valentine.ComposerFixtures

    @invalid_attrs %{comments: nil, content: nil, status: nil, tags: nil}

    test "list_application_informations/0 returns all application_informations" do
      application_information = application_information_fixture()
      assert Composer.list_application_informations() == [application_information]
    end

    test "get_application_information!/1 returns the application_information with given id" do
      application_information = application_information_fixture()

      assert Composer.get_application_information!(application_information.id) ==
               application_information
    end

    test "create_application_information/1 with valid data creates a application_information" do
      workspace = workspace_fixture()

      valid_attrs = %{
        content: "some content",
        workspace_id: workspace.id
      }

      assert {:ok, %ApplicationInformation{} = application_information} =
               Composer.create_application_information(valid_attrs)

      assert application_information.content == "some content"
    end

    test "create_application_information/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Composer.create_application_information(@invalid_attrs)
    end

    test "update_application_information/2 with valid data updates the application_information" do
      application_information = application_information_fixture()

      update_attrs = %{
        content: "some updated content"
      }

      assert {:ok, %ApplicationInformation{} = application_information} =
               Composer.update_application_information(application_information, update_attrs)

      assert application_information.content == "some updated content"
    end

    test "update_application_information/2 with invalid data returns error changeset" do
      application_information = application_information_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Composer.update_application_information(application_information, @invalid_attrs)

      assert application_information ==
               Composer.get_application_information!(application_information.id)
    end

    test "delete_application_information/1 deletes the application_information" do
      application_information = application_information_fixture()

      assert {:ok, %ApplicationInformation{}} =
               Composer.delete_application_information(application_information)

      assert_raise Ecto.NoResultsError, fn ->
        Composer.get_application_information!(application_information.id)
      end
    end

    test "change_application_information/1 returns a application_information changeset" do
      application_information = application_information_fixture()
      assert %Ecto.Changeset{} = Composer.change_application_information(application_information)
    end
  end

  describe "data_flow_diagrams" do
    alias Valentine.Composer.DataFlowDiagram

    import Valentine.ComposerFixtures

    @invalid_attrs %{comments: nil, content: nil, status: nil, tags: nil}

    test "list_data_flow_diagrams/0 returns all data_flow_diagrams" do
      data_flow_diagram = data_flow_diagram_fixture()

      assert hd(Composer.list_data_flow_diagrams()).id == data_flow_diagram.id
    end

    test "get_data_flow_diagram_by_workspace_id/1 returns the data_flow_diagram with given workspace_id" do
      data_flow_diagram = data_flow_diagram_fixture()

      assert Composer.get_data_flow_diagram_by_workspace_id(data_flow_diagram.workspace_id).id ==
               data_flow_diagram.id
    end

    test "get_data_flow_diagram!/1 returns the data_flow_diagram with given id" do
      data_flow_diagram = data_flow_diagram_fixture()

      assert Composer.get_data_flow_diagram!(data_flow_diagram.id).id ==
               data_flow_diagram.id
    end

    test "create_data_flow_diagram/1 with valid data creates a data_flow_diagram" do
      workspace = workspace_fixture()

      valid_attrs = %{
        edges: %{},
        nodes: %{},
        workspace_id: workspace.id
      }

      assert {:ok, %DataFlowDiagram{} = data_flow_diagram} =
               Composer.create_data_flow_diagram(valid_attrs)

      assert data_flow_diagram.edges == %{}
      assert data_flow_diagram.nodes == %{}
    end

    test "create_data_flow_diagram/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Composer.create_data_flow_diagram(@invalid_attrs)
    end

    test "update_data_flow_diagram/2 with valid data updates the data_flow_diagram" do
      data_flow_diagram = data_flow_diagram_fixture()

      update_attrs = %{
        edges: %{"foo" => "bar"}
      }

      assert {:ok, %DataFlowDiagram{} = data_flow_diagram} =
               Composer.update_data_flow_diagram(data_flow_diagram, update_attrs)

      assert data_flow_diagram.edges == %{"foo" => "bar"}
    end

    test "update_data_flow_diagram/2 with invalid data returns error changeset" do
      data_flow_diagram = data_flow_diagram_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Composer.update_data_flow_diagram(data_flow_diagram, %{edges: nil})

      assert data_flow_diagram ==
               Composer.get_data_flow_diagram!(data_flow_diagram.id)
    end

    test "delete_data_flow_diagram/1 deletes the data_flow_diagram" do
      data_flow_diagram = data_flow_diagram_fixture()

      assert {:ok, %DataFlowDiagram{}} =
               Composer.delete_data_flow_diagram(data_flow_diagram)

      assert_raise Ecto.NoResultsError, fn ->
        Composer.get_data_flow_diagram!(data_flow_diagram.id)
      end
    end

    test "change_data_flow_diagram/1 returns a data_flow_diagram changeset" do
      data_flow_diagram = data_flow_diagram_fixture()
      assert %Ecto.Changeset{} = Composer.change_data_flow_diagram(data_flow_diagram)
    end
  end
end
