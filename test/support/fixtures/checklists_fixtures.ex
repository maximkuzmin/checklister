defmodule Checklister.ChecklistsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Checklister.Checklists` context.
  """

  @doc """
  Generate a checklist.
  """
  def checklist_fixture(attrs \\ %{}) do
    {:ok, checklist} =
      attrs
      |> Enum.into(%{
        entries: [],
        is_template: true,
        name: "some name"
      })
      |> Checklister.Checklists.create_checklist()

    checklist
  end
end
