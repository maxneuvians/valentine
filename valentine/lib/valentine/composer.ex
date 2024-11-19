defmodule Valentine.Composer do
  @moduledoc """
  The Composer context.
  """

  import Ecto.Query, warn: false
  alias Valentine.Repo

  alias Valentine.Composer.Workspace

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
  def get_workspace!(id), do: Repo.get!(Workspace, id)

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

  alias Valentine.Composer.Threat

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

  alias Valentine.Composer.Assumption

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
  Returns the list of assumptions for a specific workspace.

  ## Examples

      iex> list_assumptions_by_workspace(123)
      [%Assumption{workspace_id: 123}, ...]

  """
  def list_assumptions_by_workspace(workspace_id) do
    from(t in Assumption, where: t.workspace_id == ^workspace_id)
    |> Repo.all()
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
end
