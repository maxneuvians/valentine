defmodule Valentine.Repo.Migrations.CreateArchitectures do
  use Ecto.Migration

  def change do
    create table(:architectures, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :content, :text
      add :image, :text
      add :workspace_id, references(:workspaces, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:architectures, [:workspace_id])
    create unique_index(:architectures, [:id])
  end
end
