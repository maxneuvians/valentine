defmodule Valentine.Repo.Migrations.CreateControls do
  use Ecto.Migration

  def change do
    create table(:controls, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :class, :string
      add :description, :text
      add :name, :string
      add :nist_id, :string
      add :nist_family, :string
      add :guidance, :text
      add :stride, {:array, :string}
      add :tags, {:array, :string}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:controls, [:id])
  end
end
