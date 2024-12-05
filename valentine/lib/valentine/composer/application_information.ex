defmodule Valentine.Composer.ApplicationInformation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Valentine.Cache

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "application_informations" do
    belongs_to :workspace, Valentine.Composer.Workspace

    field :content, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(application_information, attrs) do
    application_information
    |> cast(attrs, [:content, :workspace_id])
    |> validate_required([:workspace_id])
  end

  def flush_cache(workspace_id) do
    Cache.put({__MODULE__, :application_information, workspace_id}, [])
    []
  end

  def get_cache(workspace_id) do
    case Cache.get({__MODULE__, :application_information, workspace_id}) do
      nil -> flush_cache(workspace_id)
      stack -> stack
    end
  end

  def push_cache(workspace_id, ops) do
    new_stack =
      workspace_id
      |> get_cache()
      |> Kernel.++(ops)

    Cache.put({__MODULE__, :application_information, workspace_id}, new_stack)
    new_stack
  end
end
