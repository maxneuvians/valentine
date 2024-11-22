defmodule Valentine.Composer.MitigationThreat do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "mitigations_threats" do
    belongs_to :mitigation, Valentine.Composer.Mitigation
    belongs_to :threat, Valentine.Composer.Threat
    timestamps()
  end
end
