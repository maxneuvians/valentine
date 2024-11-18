defmodule Valentine.Composer.Threat do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder,
           only: [
             :id,
             :workspace_id,
             :numeric_id,
             :status,
             :priority,
             :stride,
             :comments,
             :threat_source,
             :prerequisites,
             :threat_action,
             :threat_impact,
             :impacted_goal,
             :impacted_assets,
             :tags
           ]}

  schema "threats" do
    belongs_to :workspace, Valentine.Composer.Workspace

    field :numeric_id, :integer
    field :status, Ecto.Enum, values: [:identified, :resolved, :not_useful]
    field :priority, Ecto.Enum, values: [:low, :medium, :high]

    field :stride,
          {:array, Ecto.Enum},
          values: [
            :spoofing,
            :tampering,
            :repudiation,
            :information_disclosure,
            :denial_of_service,
            :elevation_of_privilege
          ]

    field :comments, :string
    field :threat_source, :string
    field :prerequisites, :string
    field :threat_action, :string
    field :threat_impact, :string
    field :impacted_goal, {:array, :string}
    field :impacted_assets, {:array, :string}
    field :tags, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(threat, attrs) do
    threat
    |> cast(attrs, [
      :workspace_id,
      :status,
      :priority,
      :stride,
      :comments,
      :threat_source,
      :prerequisites,
      :threat_action,
      :threat_impact,
      :impacted_goal,
      :impacted_assets,
      :tags
    ])
    |> validate_required([
      :workspace_id,
      :threat_source,
      :prerequisites,
      :threat_action,
      :threat_impact,
      :impacted_assets
    ])
    |> set_numeric_id()
    |> unique_constraint(:numeric_id, name: :threats_workspace_id_numeric_id_index)
    |> unique_constraint(:id)
    |> foreign_key_constraint(:workspace_id)
  end

  defp set_numeric_id(changeset) do
    case get_field(changeset, :numeric_id) do
      nil ->
        case get_field(changeset, :workspace_id) do
          nil ->
            changeset

          workspace_id ->
            last_threat =
              Valentine.Repo.one(
                from t in __MODULE__,
                  where: t.workspace_id == ^workspace_id,
                  order_by: [desc: t.numeric_id],
                  limit: 1
              )

            put_change(changeset, :numeric_id, (last_threat && last_threat.numeric_id + 1) || 1)
        end

      _ ->
        changeset
    end
  end
end
