defmodule Valentine.Repo.Migrations.CreateReferencePackItems do
  use Ecto.Migration

  def change do
    create table(:reference_pack_items, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string
      add :description, :text
      add :collection_id, :uuid
      add :collection_type, :string
      add :collection_name, :string
      add :data, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:reference_pack_items, [:id])
    create index(:reference_pack_items, [:collection_id])
  end
end
