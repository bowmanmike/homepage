defmodule Homepage.SortableList.List do
  use Ecto.Schema
  import Ecto.Changeset

  alias Homepage.SortableList

  schema "lists" do
    field :title, :string

    has_many :items, SortableList.Item

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
