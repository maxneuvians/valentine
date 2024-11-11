defmodule Valentine.Composer.Workspace do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "workspaces" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
