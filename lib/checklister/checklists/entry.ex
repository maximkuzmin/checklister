defmodule Checklister.Checklists.Entry do
  use Ecto.Schema



  @primary_key {:id, Ecto.UUID, autogenerate: true}

  embedded_schema do
    # field :id, Ecto.UUID, autogenerate: true
    field :name, :string
    field :is_done, :boolean

    embeds_many :entries, __MODULE__, on_replace: :delete

    timestamps(type: :utc_datetime)
  end


  def changeset(entry \\ %__MODULE__{}, params) do
    entry
    |> Ecto.Changeset.cast(params, [:name, :is_done])
    |> Ecto.Changeset.cast_embed(:entries, on_replace: :update)
  end
end