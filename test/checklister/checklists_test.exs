defmodule Checklister.ChecklistsTest do
  use Checklister.DataCase
  alias Checklister.Checklists

  describe "checklists" do
    alias Checklister.Checklists.Checklist
    alias Checklister.Checklists.Entry

    import Checklister.ChecklistsFixtures

    @invalid_attrs %{name: nil, entries: nil, is_template: nil}

    test "list_checklists/0 returns all checklists" do
      checklist = checklist_fixture()
      assert Checklists.list_checklists() == [checklist]
    end

    test "get_checklist!/1 returns the checklist with given id" do
      checklist = checklist_fixture()
      assert Checklists.get_checklist!(checklist.id) == checklist
    end

    test "create_checklist/1 with valid data creates a checklist" do
      valid_attrs = %{name: "some name", entries: [], is_template: true}

      assert {:ok, %Checklist{} = checklist} = Checklists.create_checklist(valid_attrs)
      assert checklist.name == "some name"
      assert checklist.entries == []
      assert checklist.is_template == true
    end

    test "create_checklist/1 with valid data creates a checklist with nested entries" do
      valid_attrs = checklist_fixture_params()
      assert {:ok, %Checklist{entries: entries}} = Checklists.create_checklist(valid_attrs)
      assert is_list(entries)
      assert [%Entry{name: "First level entry", entries: subentries} | _] = entries
      assert is_list(subentries)
      assert [%Entry{name: "Second level entry"}]
    end

    test "create_checklist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checklists.create_checklist(@invalid_attrs)
    end

    test "create_checklist/1 with invalid entries params returns error changeser" do
      invalid_params = checklist_fixture_params(%{entries: [%{}]})

      assert {:error, %Ecto.Changeset{valid?: false}} =
               Checklists.create_checklist(invalid_params)
    end

    test "update_checklist/2 with valid data updates the checklist" do
      %Checklist{entries: [%Entry{id: entry_id} | _]} = checklist = checklist_fixture()

      update_attrs = %{
        name: "some updated name",
        entries: [
          %{id: entry_id, name: "updated_entry_name"}
        ],
        is_template: false
      }

      assert {:ok, %Checklist{} = checklist} =
               Checklists.update_checklist(checklist, update_attrs)

      assert checklist.name == "some updated name"

      assert [
               %Entry{
                 id: ^entry_id,
                 name: "updated_entry_name",
                 entries: [%Entry{} | _]
               }
               | _
             ] = checklist.entries

      assert checklist.is_template == false
    end

    test "update_checklist/2 with invalid data returns error changeset" do
      checklist = checklist_fixture()
      assert {:error, %Ecto.Changeset{}} = Checklists.update_checklist(checklist, @invalid_attrs)
      assert checklist == Checklists.get_checklist!(checklist.id)
    end

    test "update_checklist/2 with invalid data for entries returns error changeset" do
      invalid_attrs = %{entries: [%{}]}
      checklist = checklist_fixture()
      assert {:error, %Ecto.Changeset{}} = Checklists.update_checklist(checklist, invalid_attrs)
      assert checklist == Checklists.get_checklist!(checklist.id)
    end

    test "delete_checklist/1 deletes the checklist" do
      checklist = checklist_fixture()
      assert {:ok, %Checklist{}} = Checklists.delete_checklist(checklist)
      assert_raise Ecto.NoResultsError, fn -> Checklists.get_checklist!(checklist.id) end
    end

    test "change_checklist/1 returns a checklist changeset" do
      checklist = checklist_fixture()
      assert %Ecto.Changeset{} = Checklists.change_checklist(checklist)
    end

    test "add_entry/3 adds an entry to a checklist" do
      entry_params = %{name: "added entry"}
      checklist = checklist_fixture()

      result = Checklists.add_entry!(checklist, entry_params)

      last_saved_entry = result.entries |> Enum.at(-1)
      assert %Entry{id: id, name: "added entry"} = last_saved_entry
      assert {:ok, _} = Ecto.UUID.dump(id)
    end

    test "add_entry!/3 adds entry to nested entry using path of ids" do
      expected_name = "Second level entry # 2"
      checklist = checklist_fixture()
      entry_params = %{name: "Second level entry # 2"}

      [%Entry{id: parent_entry_id} | _] = checklist.entries
      path = [parent_entry_id]

      result = Checklists.add_entry!(checklist, path, entry_params)

      assert %Checklist{} = result

      assert %Entry{id: ^parent_entry_id, entries: [_, %Entry{id: id, name: ^expected_name}]} =
               result.entries |> List.first()

      assert {:ok, _} = Ecto.UUID.dump(id)
    end

    test "delete_entry!/3 removes entry from first level of checklist on nested collections" do
      %{
        entries: [_ | [parent_of_to_be_deleted | _]]
      } = checklist = checklist_fixture()

      %{entries: [entry_to_be_left, entry_to_be_deleted]} = parent_of_to_be_deleted

      path = [parent_of_to_be_deleted.id, entry_to_be_deleted.id]

      result = Checklists.delete_entry!(checklist, path)

      assert %Checklist{
               entries: [
                 _,
                 %Entry{id: parent_id, entries: [%Entry{} = entry_left]},
                 _
               ]
             } = result

      assert parent_of_to_be_deleted.id == parent_id
      assert entry_left == entry_to_be_left
    end

    test "delete_entry!/3 removes entry from first level of checklist" do
      %{entries: subentries} = checklist = checklist_fixture()
      [entry_to_be_left | [entry_to_be_deleted | rest]] = subentries

      path = [entry_to_be_deleted.id]

      result = Checklists.delete_entry!(checklist, path)

      assert %Checklist{
               entries: [entry_left | whats_rest]
             } = result

      assert entry_left == entry_to_be_left
      assert rest == whats_rest
    end

    test "update_entry!/3 updates existing entry on first level of checklist" do
      %{entries: entries} = checklist = checklist_fixture()
      entry = entries |> Enum.at(1)
      expected_name = "Changed entry name"
      id = entry.id
      path = [id]
      update_entry_params = %{"name" => expected_name}

      assert %Checklist{entries: entries} =
               Checklists.update_entry!(checklist, path, update_entry_params)

      updated_subentry = entries |> Enum.at(1)
      assert %Entry{id: ^id, name: ^expected_name} = updated_subentry
    end

    test "update_entry!/3 updates existing entry on deeper levels of checklist" do
      %{entries: entries} = checklist = checklist_fixture()
      first_level_entry = entries |> Enum.at(1)
      expected_name = "Changed entry name"
      second_level_entry = first_level_entry.entries |> Enum.at(1)
      id = second_level_entry.id
      path = [first_level_entry.id, id]

      update_entry_params = %{"name" => expected_name}

      assert %Checklist{entries: entries} =
               Checklists.update_entry!(checklist, path, update_entry_params)

      updated_first_level_subentry = entries |> Enum.at(1)
      updated_second_level_subentry = updated_first_level_subentry.entries |> Enum.at(1)
      assert %Entry{id: ^id, name: ^expected_name} = updated_second_level_subentry
    end
  end
end
