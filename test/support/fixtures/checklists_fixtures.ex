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
      checklist_fixture_params(attrs)
      |> Checklister.Checklists.create_checklist()

    checklist
  end

  @spec checklist_fixture_params(any()) :: any()
  def checklist_fixture_params(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      entries: [
        %{
          "name" => "First level entry",
          "is_done" => false,
          "entries" => [
            %{
              "name" => "Second level entry",
              "is_done" => true
            }
          ]
        },
        %{
          "name" => "First level entry #2",
          "is_done" => false,
          "entries" => [
            %{
              "name" => "Second level entry #2",
              "is_done" => true
            } ,
            %{
              "name" => "Second level entry #3",
              "is_done" => true
            }
          ]
        }
      ],
      is_template: true,
      name: "some name"
    })
  end
end
