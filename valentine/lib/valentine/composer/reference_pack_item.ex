defmodule Valentine.Composer.ReferencePackItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :description,
             :collection_id,
             :collection_type,
             :collection_name,
             :data
           ]}

  schema "reference_pack_items" do
    field :name, :string
    field :description, :string
    field :collection_id, :binary_id
    field :collection_type, Ecto.Enum, values: [:assumption, :mitigation, :threat]
    field :collection_name, :string
    field :data, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reference_pack_item, attrs) do
    reference_pack_item
    |> cast(attrs, [
      :name,
      :description,
      :collection_id,
      :collection_type,
      :collection_name,
      :data
    ])
    |> validate_required([:name, :collection_id, :collection_type, :collection_name, :data])
    |> unique_constraint(:id)
  end
end
