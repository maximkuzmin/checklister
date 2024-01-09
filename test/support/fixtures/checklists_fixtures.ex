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
        entries: [
          %{
            "name" => "Test entry",
            "is_done" => false,
            "entries" => [%{
              "name" => "Inner entry",
              "is_done" => true,
            }]
          }
        ],
        is_template: true,
        name: "some name"
      })
      |> Checklister.Checklists.create_checklist()

    checklist
  end
end
