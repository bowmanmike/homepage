defmodule Homepage.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :position, :integer
      add :list_id, :integer

      timestamps()
    end
  end
end
