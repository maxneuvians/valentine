defmodule Valentine.Repo.Migrations.CreateThreats do
  use Ecto.Migration

  def change do
    create table(:threats, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :numeric_id, :integer
      add :status, :string
      add :priority, :string
      add :stride, {:array, :string}
      add :comments, :text
      add :threat_source, :string
      add :prerequisites, :text
      add :threat_action, :text
      add :threat_impact, :text
      add :impacted_goal, {:array, :string}
      add :impacted_assets, {:array, :string}
      add :tags, {:array, :string}
      add :workspace_id, references(:workspaces, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:threats, [:workspace_id])
    create unique_index(:threats, [:id])
  end
end
