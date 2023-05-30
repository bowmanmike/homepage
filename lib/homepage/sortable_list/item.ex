defmodule Homepage.SortableList.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Homepage.SortableList

  schema "items" do
    # field :list_id, :integer
    field :name, :string
    field :position, :integer

    belongs_to :list, SortableList.List

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :position, :list_id])
    |> validate_required([:name, :position, :list_id])
  end
end
