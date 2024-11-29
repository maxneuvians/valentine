defmodule Valentine.Repo.Migrations.CreateApplicationInformation do
  use Ecto.Migration

  def change do
    create table(:application_informations, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :content, :string
      add :workspace_id, references(:workspaces, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:application_informations, [:workspace_id])
    create unique_index(:application_informations, [:id])
  end
end
