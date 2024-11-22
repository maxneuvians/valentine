defmodule Valentine.Composer.AssumptionThreat do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "assumptions_threats" do
    belongs_to :assumption, Valentine.Composer.Assumption
    belongs_to :threat, Valentine.Composer.Threat
    timestamps()
  end
end
