defmodule Valentine.Repo.Migrations.CreateThreats do
  use Ecto.Migration

  def change do
    create table(:threats, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :source, :string
      add :prerequisite, :string
      add :action, :string
      add :impact, :string
      add :goal, :string
      add :asset, :string

      timestamps(type: :utc_datetime)
    end
  end
end
