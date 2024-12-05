defmodule Valentine.Repo.Migrations.CreateAssumptionsMitigationss do
  use Ecto.Migration

  def change do
    create table(:assumptions_mitigations, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add(:assumption_id, references(:assumptions, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      add(:mitigation_id, references(:mitigations, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      timestamps(type: :utc_datetime)
    end

    create index(:assumptions_mitigations, [:assumption_id])
    create index(:assumptions_mitigations, [:mitigation_id])
    create unique_index(:assumptions_mitigations, [:assumption_id, :mitigation_id])
  end
end
