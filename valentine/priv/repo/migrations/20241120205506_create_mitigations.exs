defmodule Valentine.Repo.Migrations.CreateMitigations do
  use Ecto.Migration

  def change do
    create table(:mitigations, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :numeric_id, :integer
      add :content, :string
      add :comments, :string
      add :tags, {:array, :string}
      add :workspace_id, references(:workspaces, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:mitigations, [:workspace_id])
    create unique_index(:mitigations, [:id])
  end
end
