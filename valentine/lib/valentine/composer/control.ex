defmodule Valentine.Composer.Control do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :description,
             :nist_id,
             :nist_family,
             :stride,
             :tags
           ]}

  schema "controls" do
    field :name, :string
    field :description, :string
    field :nist_id, :string
    field :nist_family, :string

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

    field :tags, {:array, :string}

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reference_pack_item, attrs) do
    reference_pack_item
    |> cast(attrs, [
      :name,
      :description,
      :nist_id,
      :nist_family,
      :stride,
      :tags
    ])
    |> validate_required([:name, :description, :nist_id, :nist_family])
    |> unique_constraint(:id)
  end
end
