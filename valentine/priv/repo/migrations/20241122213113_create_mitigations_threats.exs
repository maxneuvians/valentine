defmodule Valentine.Repo.Migrations.CreateMitigationsThreats do
  use Ecto.Migration

  def change do
    create table(:mitigations_threats, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add(:mitigation_id, references(:mitigations, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      add(:threat_id, references(:threats, on_delete: :delete_all, type: :binary_id),
        primary_key: true
      )

      timestamps(type: :utc_datetime)
    end

    create index(:mitigations_threats, [:mitigation_id])
    create index(:mitigations_threats, [:threat_id])
    create unique_index(:mitigations_threats, [:mitigation_id, :threat_id])
  end
end
