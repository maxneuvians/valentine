defmodule Valentine.Composer.Threat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "threats" do
    field :source, :string
    field :action, :string
    field :prerequisite, :string
    field :impact, :string
    field :goal, :string
    field :asset, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(threat, attrs) do
    threat
    |> cast(attrs, [:source, :prerequisite, :action, :impact, :goal, :asset])
    |> validate_required([:source, :prerequisite, :action, :impact, :asset])
  end
end
