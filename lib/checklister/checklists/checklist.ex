defmodule Checklister.Checklists.Checklist do
  use Ecto.Schema

  alias Checklister.Checklists.Entry

  import Ecto.Changeset

  schema "checklists" do
    field :name, :string
    field :is_template, :boolean, default: false

    embeds_many :entries, Entry, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @cast_fields [:name, :is_template]

  @doc false
  def changeset(checklist, attrs) do
    checklist
    |> cast(attrs, @cast_fields)
    |> validate_required(@cast_fields)
    |> cast_embed(:entries, on_replace: :update)
  end
end
