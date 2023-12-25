defmodule Checklister.Checklists.Checklist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checklists" do
    field :name, :string
    field :entries, {:array, :map}
    field :is_template, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(checklist, attrs) do
    checklist
    |> cast(attrs, [:name, :entries, :is_template])
    |> validate_required([:name, :is_template])
  end
end
