defmodule Valentine.Repo.Migrations.CreateAssumptions do
  use Ecto.Migration

  def change do
    create table(:assumptions, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :numeric_id, :integer
      add :content, :string
      add :comments, :string
      add :tags, {:array, :string}
      add :workspace_id, references(:workspaces, type: :binary_id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:assumptions, [:workspace_id])
    create unique_index(:assumptions, [:id])
  end
end
