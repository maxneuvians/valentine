defmodule Valentine.Repo.Migrations.CreateDataFlowDiagrams do
  use Ecto.Migration

  def change do
    create table(:data_flow_diagrams, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :edges, :map, null: false, default: %{}
      add :nodes, :map, null: false, default: %{}
      add :workspace_id, references(:workspaces, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:data_flow_diagrams, [:workspace_id])
    create unique_index(:data_flow_diagrams, [:id])
  end
end
