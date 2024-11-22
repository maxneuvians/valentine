defmodule Valentine.Repo.Migrations.CreateAssumptionsThreats do
  use Ecto.Migration

  def change do
    create table(:assumptions_threats, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add(:assumption_id, references(:assumptions, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      add(:threat_id, references(:threats, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      timestamps(type: :utc_datetime)
    end

    create index(:assumptions_threats, [:assumption_id])
    create index(:assumptions_threats, [:threat_id])
    create unique_index(:assumptions_threats, [:assumption_id, :threat_id])
  end
end
