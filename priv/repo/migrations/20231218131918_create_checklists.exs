defmodule Checklister.Repo.Migrations.CreateChecklists do
  use Ecto.Migration

  def change do
    create table(:checklists) do
      add :name, :string
      add :entries, {:array, :map}
      add :is_template, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
