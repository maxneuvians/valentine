defmodule Valentine.Composer.Architecture do
  use Ecto.Schema
  import Ecto.Changeset

  alias Valentine.Cache

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "architectures" do
    belongs_to :workspace, Valentine.Composer.Workspace

    field :content, :string
    field :image, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(architecture, attrs) do
    architecture
    |> cast(attrs, [:content, :image, :workspace_id])
    |> validate_required([:workspace_id])
  end

  def flush_cache(workspace_id) do
    Cache.put({__MODULE__, :architecture, workspace_id}, [])
    []
  end

  def get_cache(workspace_id) do
    case Cache.get({__MODULE__, :architecture, workspace_id}) do
      nil -> flush_cache(workspace_id)
      stack -> stack
    end
  end

  def push_cache(workspace_id, ops) do
    new_stack =
      workspace_id
      |> get_cache()
      |> Kernel.++(ops)

    Cache.put({__MODULE__, :architecture, workspace_id}, new_stack)
    new_stack
  end
end
