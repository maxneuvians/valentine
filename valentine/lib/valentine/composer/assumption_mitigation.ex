defmodule Valentine.Composer.AssumptionMitigation do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "assumptions_mitigations" do
    belongs_to :assumption, Valentine.Composer.Assumption
    belongs_to :mitigation, Valentine.Composer.Mitigation
    timestamps()
  end
end
