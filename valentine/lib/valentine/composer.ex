defmodule Valentine.Composer do
  @moduledoc """
  The Composer context.
  """

  import Ecto.Query, warn: false
  alias Valentine.Repo

  alias Valentine.Composer.Workspace
  alias Valentine.Composer.Assumption
  alias Valentine.Composer.Mitigation
  alias Valentine.Composer.Threat
  alias Valentine.Composer.ApplicationInformation
  alias Valentine.Composer.DataFlowDiagram
  alias Valentine.Composer.Architecture

  alias Valentine.Composer.AssumptionThreat
  alias Valentine.Composer.AssumptionMitigation
  alias Valentine.Composer.MitigationThreat

  @doc """
  Returns the list of workspaces.

  ## Examples

      iex> list_workspaces()
      [%Workspace{}, ...]

  """
  def list_workspaces do
    Repo.all(Workspace)
  end

  @doc """
  Gets a single workspace.

  Raises `Ecto.NoResultsError` if the Workspace does not exist.

  ## Examples

      iex> get_workspace!(123)
      %Workspace{}

      iex> get_workspace!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workspace!(id, _preload \\ nil)

  def get_workspace!(id, preload) when is_list(preload) do
    Repo.get!(Workspace, id)
    |> Repo.preload(preload)
  end

  def get_workspace!(id, preload) when is_nil(preload), do: Repo.get!(Workspace, id)

  @doc """
  Creates a workspace.

  ## Examples

      iex> create_workspace(%{field: value})
      {:ok, %Workspace{}}

      iex> create_workspace(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workspace(attrs \\ %{}) do
    %Workspace{}
    |> Workspace.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a workspace.

  ## Examples

      iex> update_workspace(workspace, %{field: new_value})
      {:ok, %Workspace{}}

      iex> update_workspace(workspace, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workspace(%Workspace{} = workspace, attrs) do
    workspace
    |> Workspace.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a workspace.

  ## Examples

      iex> delete_workspace(workspace)
      {:ok, %Workspace{}}

      iex> delete_workspace(workspace)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workspace(%Workspace{} = workspace) do
    Repo.delete(workspace)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workspace changes.

  ## Examples

      iex> change_workspace(workspace)
      %Ecto.Changeset{data: %Workspace{}}

  """
  def change_workspace(%Workspace{} = workspace, attrs \\ %{}) do
    Workspace.changeset(workspace, attrs)
  end

  @doc """
  Returns the list of threats.

  ## Examples

      iex> list_threats()
      [%Threat{}, ...]

  """
  def list_threats do
    Repo.all(Threat)
  end

  @doc """
  Filters threats based on enum field values.

  Takes a queryable and a map of filters where keys are field names and values are selected enum values.
  Handles both array and parameterized enum fields.

  ## Examples

      iex> filters = %{severity: ["HIGH", "CRITICAL"], status: ["OPEN"]}
      iex> list_threats_with_enum_filters(Threat, filters)
      [%Threat{severity: "HIGH", status: "OPEN"}, ...]

  """
  def list_threats_with_enum_filters(m, filters) do
    Enum.reduce(filters, m, fn {f, selected}, queryable ->
      case Threat.__schema__(:type, f) do
        {:array, _} ->
          if is_nil(selected) || selected == [] do
            queryable
          else
            [first | rest] = selected
            query = where(queryable, [m], ^first in field(m, ^f))

            Enum.reduce(rest, query, fn s, q ->
              or_where(q, [m], ^s in field(m, ^f))
            end)
          end

        {:parameterized, _} ->
          if is_nil(selected) || selected == [] do
            queryable
          else
            where(queryable, [m], field(m, ^f) in ^selected)
          end
      end
    end)
  end

  @doc """
  Returns the list of threats for a specific workspace.

  ## Parameters

    * workspace_id - The UUID of the workspace to filter threats by

  ## Examples

      iex> list_threats_by_workspace("123e4567-e89b-12d3-a456-426614174000")
      [%Threat{}, ...]

      iex> list_threats_by_workspace("nonexistent-id")
      []
  """
  def list_threats_by_workspace(workspace_id, enum_filters \\ %{}) do
    from(t in Threat, where: t.workspace_id == ^workspace_id)
    |> list_threats_with_enum_filters(enum_filters)
    |> Repo.all()
  end

  @doc """
  Gets a single threat.

  Raises `Ecto.NoResultsError` if the Threat does not exist.

  ## Examples

      iex> get_threat!(123)
      %Threat{}

      iex> get_threat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_threat!(id), do: Repo.get!(Threat, id)

  @doc """
  Creates a threat.

  ## Examples

      iex> create_threat(%{field: value})
      {:ok, %Threat{}}

      iex> create_threat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_threat(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:threat, fn _ ->
      %Threat{}
      |> Threat.changeset(attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{threat: threat}} -> {:ok, threat}
      {:error, :threat, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Updates a threat.

  ## Examples

      iex> update_threat(threat, %{field: new_value})
      {:ok, %Threat{}}

      iex> update_threat(threat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_threat(%Threat{} = threat, attrs) do
    threat
    |> Threat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a threat.

  ## Examples

      iex> delete_threat(threat)
      {:ok, %Threat{}}

      iex> delete_threat(threat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_threat(%Threat{} = threat) do
    Repo.delete(threat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking threat changes.

  ## Examples

      iex> change_threat(threat)
      %Ecto.Changeset{data: %Threat{}}

  """
  def change_threat(%Threat{} = threat, attrs \\ %{}) do
    Threat.changeset(threat, attrs)
  end

  @doc """
  Returns the list of assumptions.

  ## Examples

      iex> list_assumptions()
      [%Assumption{}, ...]

  """
  def list_assumptions do
    Repo.all(Assumption)
  end

  @doc """
  Gets a single assumption.

  Raises `Ecto.NoResultsError` if the Assumption does not exist.

  ## Examples

      iex> get_assumption!(123)
      %Assumption{}

      iex> get_assumption!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assumption!(id), do: Repo.get!(Assumption, id)

  @doc """
  Creates a assumption.

  ## Examples

      iex> create_assumption(%{field: value})
      {:ok, %Assumption{}}

      iex> create_assumption(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assumption(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:assumption, fn _ ->
      %Assumption{}
      |> Assumption.changeset(attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{assumption: assumption}} -> {:ok, assumption}
      {:error, :assumption, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Updates a assumption.

  ## Examples

      iex> update_assumption(assumption, %{field: new_value})
      {:ok, %Assumption{}}

      iex> update_assumption(assumption, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assumption(%Assumption{} = assumption, attrs) do
    assumption
    |> Assumption.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a assumption.

  ## Examples

      iex> delete_assumption(assumption)
      {:ok, %Assumption{}}

      iex> delete_assumption(assumption)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assumption(%Assumption{} = assumption) do
    Repo.delete(assumption)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assumption changes.

  ## Examples

      iex> change_assumption(assumption)
      %Ecto.Changeset{data: %Assumption{}}

  """
  def change_assumption(%Assumption{} = assumption, attrs \\ %{}) do
    Assumption.changeset(assumption, attrs)
  end

  @doc """
  Returns the list of mitigations.

  ## Examples

      iex> list_mitigations()
      [%Mitigation{}, ...]

  """
  def list_mitigations do
    Repo.all(Mitigation)
  end

  @doc """
  Gets a single mitigation.

  Raises `Ecto.NoResultsError` if the Mitigation does not exist.

  ## Examples

      iex> get_mitigation!(123)
      %Mitigation{}

      iex> get_mitigation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mitigation!(id), do: Repo.get!(Mitigation, id)

  @doc """
  Creates a mitigation.

  ## Examples

      iex> create_mitigation(%{field: value})
      {:ok, %Mitigation{}}

      iex> create_mitigation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mitigation(attrs \\ %{}) do
    %Mitigation{}
    |> Mitigation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mitigation.

  ## Examples

      iex> update_mitigation(mitigation, %{field: new_value})
      {:ok, %Mitigation{}}

      iex> update_mitigation(mitigation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mitigation(%Mitigation{} = mitigation, attrs) do
    mitigation
    |> Mitigation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mitigation.

  ## Examples

      iex> delete_mitigation(mitigation)
      {:ok, %Mitigation{}}

      iex> delete_mitigation(mitigation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mitigation(%Mitigation{} = mitigation) do
    Repo.delete(mitigation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mitigation changes.

  ## Examples

      iex> change_mitigation(mitigation)
      %Ecto.Changeset{data: %Mitigation{}}

  """
  def change_mitigation(%Mitigation{} = mitigation, attrs \\ %{}) do
    Mitigation.changeset(mitigation, attrs)
  end

  @doc """
  Adds an assumption to an existing threat model.

  This function associates a security assumption with a specific threat,
  helping document the conditions under which the threat analysis remains valid.

  ## Parameters
    - threat: The threat structure to which the assumption will be added
    - assumption: The security assumption to be associated with the threat

  ## Returns
    Updated threat structure with the new assumption added

  ## Examples

      iex> add_assumption_to_threat(threat, assumption)
      %Threat{assumptions: [assumption], ...}

  """
  def add_assumption_to_threat(%Threat{} = threat, %Assumption{} = assumption) do
    %AssumptionThreat{assumption_id: assumption.id, threat_id: threat.id}
    |> Repo.insert()
    |> case do
      {:ok, _} -> {:ok, threat |> Repo.preload(:assumptions, force: true)}
      {:error, _} -> {:error, threat}
    end
  end

  @doc """
  Removes a specific assumption from a threat model.

  This function removes an existing security assumption from a threat,
  maintaining the threat model's accuracy when assumptions no longer apply.

  ## Parameters
    - threat: The threat structure from which the assumption will be removed
    - assumption: The security assumption to be removed

  ## Returns
    Updated threat structure with the specified assumption removed

  ## Examples

      iex> remove_assumption_from_threat(threat, assumption)
      %Threat{assumptions: [], ...}

  """
  def remove_assumption_from_threat(%Threat{} = threat, %Assumption{} = assumption) do
    Repo.delete_all(
      from(at in AssumptionThreat,
        where: at.assumption_id == ^assumption.id and at.threat_id == ^threat.id
      )
    )
    |> case do
      {1, nil} -> {:ok, threat |> Repo.preload(:assumptions, force: true)}
      {:error, _} -> {:error, threat}
    end
  end

  @doc """
  Adds an mitigation to an existing threat model.

  This function associates a security mitigation with a specific threat,
  helping document the conditions under which the threat analysis remains valid.

  ## Parameters
    - threat: The threat structure to which the mitigation will be added
    - mitigation: The security mitigation to be associated with the threat

  ## Returns
    Updated threat structure with the new mitigation added

  ## Examples

      iex> add_mitigation_to_threat(threat, mitigation)
      %Threat{mitigations: [mitigation], ...}

  """
  def add_mitigation_to_threat(%Threat{} = threat, %Mitigation{} = mitigation) do
    %MitigationThreat{mitigation_id: mitigation.id, threat_id: threat.id}
    |> Repo.insert()
    |> case do
      {:ok, _} -> {:ok, threat |> Repo.preload(:mitigations, force: true)}
      {:error, _} -> {:error, threat}
    end
  end

  @doc """
  Removes a specific mitigation from a threat model.

  This function removes an existing security mitigation from a threat,
  maintaining the threat model's accuracy when mitigations no longer apply.

  ## Parameters
    - threat: The threat structure from which the mitigation will be removed
    - mitigation: The security mitigation to be removed

  ## Returns
    Updated threat structure with the specified mitigation removed

  ## Examples

      iex> remove_mitigation_from_threat(threat, mitigation)
      %Threat{mitigations: [], ...}

  """
  def remove_mitigation_from_threat(%Threat{} = threat, %Mitigation{} = mitigation) do
    Repo.delete_all(
      from(at in MitigationThreat,
        where: at.mitigation_id == ^mitigation.id and at.threat_id == ^threat.id
      )
    )
    |> case do
      {1, nil} -> {:ok, threat |> Repo.preload(:mitigations, force: true)}
      {:error, _} -> {:error, threat}
    end
  end

  def add_assumption_to_mitigation(%Mitigation{} = mitigation, %Assumption{} = assumption) do
    %AssumptionMitigation{assumption_id: assumption.id, mitigation_id: mitigation.id}
    |> Repo.insert()
    |> case do
      {:ok, _} -> {:ok, mitigation |> Repo.preload(:assumptions, force: true)}
      {:error, _} -> {:error, mitigation}
    end
  end

  def remove_assumption_from_mitigation(%Mitigation{} = mitigation, %Assumption{} = assumption) do
    Repo.delete_all(
      from(am in AssumptionMitigation,
        where: am.assumption_id == ^assumption.id and am.mitigation_id == ^mitigation.id
      )
    )
    |> case do
      {1, nil} -> {:ok, mitigation |> Repo.preload(:assumptions, force: true)}
      {:error, _} -> {:error, mitigation}
    end
  end

  def add_mitigation_to_assumption(%Assumption{} = assumption, %Mitigation{} = mitigation) do
    %AssumptionMitigation{assumption_id: assumption.id, mitigation_id: mitigation.id}
    |> Repo.insert()
    |> case do
      {:ok, _} -> {:ok, assumption |> Repo.preload(:mitigations, force: true)}
      {:error, _} -> {:error, assumption}
    end
  end

  def remove_mitigation_from_assumption(%Assumption{} = assumption, %Mitigation{} = mitigation) do
    Repo.delete_all(
      from(am in AssumptionMitigation,
        where: am.assumption_id == ^assumption.id and am.mitigation_id == ^mitigation.id
      )
    )
    |> case do
      {1, nil} -> {:ok, assumption |> Repo.preload(:mitigations, force: true)}
      {:error, _} -> {:error, assumption}
    end
  end

  @doc """
  Returns the list of application_informations.

  ## Examples

      iex> list_application_informations()
      [%ApplicationInformation{}, ...]

  """
  def list_application_informations do
    Repo.all(ApplicationInformation)
  end

  @doc """
  Gets a single application_information.

  Raises `Ecto.NoResultsError` if the ApplicationInformation does not exist.

  ## Examples

      iex> get_application_information!(123)
      %ApplicationInformation{}

      iex> get_application_information!(456)
      ** (Ecto.NoResultsError)

  """
  def get_application_information!(id), do: Repo.get!(ApplicationInformation, id)

  @doc """
  Creates a application_information.

  ## Examples

      iex> create_application_information(%{field: value})
      {:ok, %ApplicationInformation{}}

      iex> create_application_information(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_application_information(attrs \\ %{}) do
    %ApplicationInformation{}
    |> ApplicationInformation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a application_information.

  ## Examples

      iex> update_application_information(application_information, %{field: new_value})
      {:ok, %ApplicationInformation{}}

      iex> update_application_information(application_information, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_application_information(%ApplicationInformation{} = application_information, attrs) do
    application_information
    |> ApplicationInformation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a application_information.

  ## Examples

      iex> delete_application_information(application_information)
      {:ok, %ApplicationInformation{}}

      iex> delete_application_information(application_information)
      {:error, %Ecto.Changeset{}}

  """
  def delete_application_information(%ApplicationInformation{} = application_information) do
    Repo.delete(application_information)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking application_information changes.

  ## Examples

      iex> change_application_information(application_information)
      %Ecto.Changeset{data: %ApplicationInformation{}}

  """
  def change_application_information(
        %ApplicationInformation{} = application_information,
        attrs \\ %{}
      ) do
    ApplicationInformation.changeset(application_information, attrs)
  end

  @doc """
  Returns the list of data_flow_diagrams.

  ## Examples

      iex> list_data_flow_diagrams()
      [%DataFlowDiagram{}, ...]

  """
  def list_data_flow_diagrams do
    Repo.all(DataFlowDiagram)
  end

  def get_data_flow_diagram_by_workspace_id(workspace_id) do
    Repo.get_by(DataFlowDiagram, workspace_id: workspace_id)
  end

  @doc """
  Gets a single data_flow_diagram.

  Raises `Ecto.NoResultsError` if the DataFlowDiagram does not exist.

  ## Examples

      iex> get_data_flow_diagram!(123)
      %DataFlowDiagram{}

      iex> get_data_flow_diagram!(456)
      ** (Ecto.NoResultsError)

  """
  def get_data_flow_diagram!(id), do: Repo.get!(DataFlowDiagram, id)

  @doc """
  Creates a data_flow_diagram.

  ## Examples

      iex> create_data_flow_diagram(%{field: value})
      {:ok, %DataFlowDiagram{}}

      iex> create_data_flow_diagram(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_data_flow_diagram(attrs \\ %{}) do
    %DataFlowDiagram{}
    |> DataFlowDiagram.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a data_flow_diagram.

  ## Examples

      iex> update_data_flow_diagram(data_flow_diagram, %{field: new_value})
      {:ok, %DataFlowDiagram{}}

      iex> update_data_flow_diagram(data_flow_diagram, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_data_flow_diagram(%DataFlowDiagram{} = data_flow_diagram, attrs) do
    data_flow_diagram
    |> DataFlowDiagram.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a data_flow_diagram.

  ## Examples

      iex> delete_data_flow_diagram(data_flow_diagram)
      {:ok, %DataFlowDiagram{}}

      iex> delete_data_flow_diagram(data_flow_diagram)
      {:error, %Ecto.Changeset{}}

  """
  def delete_data_flow_diagram(%DataFlowDiagram{} = data_flow_diagram) do
    Repo.delete(data_flow_diagram)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking data_flow_diagram changes.

  ## Examples

      iex> change_data_flow_diagram(data_flow_diagram)
      %Ecto.Changeset{data: %DataFlowDiagram{}}

  """
  def change_data_flow_diagram(
        %DataFlowDiagram{} = data_flow_diagram,
        attrs \\ %{}
      ) do
    DataFlowDiagram.changeset(data_flow_diagram, attrs)
  end

  @doc """
  Returns the list of architectures.

  ## Examples

      iex> list_architectures()
      [%Architecture{}, ...]

  """
  def list_architectures do
    Repo.all(Architecture)
  end

  @doc """
  Gets a single architecture.

  Raises `Ecto.NoResultsError` if the Architecture does not exist.

  ## Examples

      iex> get_architecture!(123)
      %Architecture{}

      iex> get_architecture!(456)
      ** (Ecto.NoResultsError)

  """
  def get_architecture!(id), do: Repo.get!(Architecture, id)

  @doc """
  Creates a architecture.

  ## Examples

      iex> create_architecture(%{field: value})
      {:ok, %Architecture{}}

      iex> create_architecture(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_architecture(attrs \\ %{}) do
    %Architecture{}
    |> Architecture.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a architecture.

  ## Examples

      iex> update_architecture(architecture, %{field: new_value})
      {:ok, %Architecture{}}

      iex> update_architecture(architecture, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_architecture(%Architecture{} = architecture, attrs) do
    architecture
    |> Architecture.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a architecture.

  ## Examples

      iex> delete_architecture(architecture)
      {:ok, %Architecture{}}

      iex> delete_architecture(architecture)
      {:error, %Ecto.Changeset{}}

  """
  def delete_architecture(%Architecture{} = architecture) do
    Repo.delete(architecture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking architecture changes.

  ## Examples

      iex> change_architecture(architecture)
      %Ecto.Changeset{data: %Architecture{}}

  """
  def change_architecture(
        %Architecture{} = architecture,
        attrs \\ %{}
      ) do
    Architecture.changeset(architecture, attrs)
  end
end
