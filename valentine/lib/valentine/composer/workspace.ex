defmodule Valentine.Composer.Workspace do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "workspaces" do
    field :name, :string

    has_one :application_information, Valentine.Composer.ApplicationInformation,
      on_delete: :delete_all

    has_one :data_flow_diagram, Valentine.Composer.DataFlowDiagram, on_delete: :delete_all

    has_many :assumptions, Valentine.Composer.Assumption, on_delete: :delete_all
    has_many :mitigations, Valentine.Composer.Mitigation, on_delete: :delete_all
    has_many :threats, Valentine.Composer.Threat, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
