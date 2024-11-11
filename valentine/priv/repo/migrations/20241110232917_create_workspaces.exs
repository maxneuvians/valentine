defmodule Valentine.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
