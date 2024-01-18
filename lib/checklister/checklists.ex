defmodule Checklister.Checklists do
  @moduledoc """
  The Checklists context.
  """

  import Ecto.Query, warn: false
  alias Checklister.Repo

  alias Checklister.Checklists.{Checklist, Entry}

  @doc """
  Returns the list of checklists.

  ## Examples

      iex> list_checklists()
      [%Checklist{}, ...]

  """
  def list_checklists do
    Repo.all(Checklist)
  end

  @doc """
  Gets a single checklist.

  Raises `Ecto.NoResultsError` if the Checklist does not exist.

  ## Examples

      iex> get_checklist!(123)
      %Checklist{}

      iex> get_checklist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_checklist!(id), do: Repo.get!(Checklist, id)

  @doc """
  Creates a checklist.

  ## Examples

      iex> create_checklist(%{field: value})
      {:ok, %Checklist{}}

      iex> create_checklist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_checklist(attrs \\ %{}) do
    %Checklist{}
    |> Checklist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a checklist.

  ## Examples

      iex> update_checklist(checklist, %{field: new_value})
      {:ok, %Checklist{}}

      iex> update_checklist(checklist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_checklist(%Checklist{} = checklist, attrs) do
    checklist
    |> Checklist.changeset(attrs)
    |> Repo.update()
  end

  def add_entry!(%Checklist{} = checklist, path \\ [], entry_params) do
    fun = fn %{entries: entries} = found_entity ->
      updated_entries = entries ++ [entry_params]
      %{found_entity | entries: updated_entries}
    end

    update_checklist_entries_with_recursive_fun(checklist, path, fun)
  end

  def delete_entry!(%Checklist{} = checklist, path) do
    fun = fn _ -> nil end

    update_checklist_entries_with_recursive_fun(checklist, path, fun)
  end

  def update_entry!(%Checklist{} = checklist, path, entry_update_params) do
    fun = fn found_entry ->
      Entry.changeset(found_entry, entry_update_params)
      |> Ecto.Changeset.apply_changes()
    end

    update_checklist_entries_with_recursive_fun(checklist, path, fun)
  end

  defp update_checklist_entries_with_recursive_fun(checklist, path, fun) do
    update_params =
      checklist
      |> find_entity_and_perform(path, fun)
      |> recursively_make_params_from_structs()
      |> Map.delete(:__meta__)

    changeset =
      checklist
      |> Ecto.Changeset.change(update_params)

    Repo.update!(changeset)
  end

  @spec find_entity_and_perform(%Checklist{} | %Entry{}, list(String.t()), fun) ::
          %Checklist{} | %Entry{}
  defp find_entity_and_perform(
         %{entries: entries} = incoming_entity,
         [next_entry_id | rest_of_path],
         fun
       ) do
    updated_entries =
      entries
      |> Enum.map(fn
        %Entry{id: ^next_entry_id} = entry ->
          find_entity_and_perform(entry, rest_of_path, fun)

        entry ->
          entry
      end)
      |> Enum.reject(&Kernel.is_nil/1)

    %{incoming_entity | entries: updated_entries}
  end

  defp find_entity_and_perform(incoming_entity, [], fun) do
    fun.(incoming_entity)
  end

  @spec recursively_make_params_from_structs(any()) :: any()
  defp recursively_make_params_from_structs(%DateTime{} = dt), do: dt

  defp recursively_make_params_from_structs(str) when is_struct(str) do
    str
    |> Map.from_struct()
    |> recursively_make_params_from_structs()
  end

  defp recursively_make_params_from_structs(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} ->
      {k, recursively_make_params_from_structs(v)}
    end)
    |> Enum.into(%{})
  end

  defp recursively_make_params_from_structs(list) when is_list(list) do
    list
    |> Enum.map(&recursively_make_params_from_structs/1)
  end

  defp recursively_make_params_from_structs({kw_key, kw_val}) when is_atom(kw_key) do
    {kw_key, kw_val}
    {kw_key, recursively_make_params_from_structs(kw_val)}
  end

  defp recursively_make_params_from_structs(val), do: val

  @doc """
  Deletes a checklist.

  ## Examples

      iex> delete_checklist(checklist)
      {:ok, %Checklist{}}

      iex> delete_checklist(checklist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_checklist(%Checklist{} = checklist) do
    Repo.delete(checklist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking checklist changes.

  ## Examples

      iex> change_checklist(checklist)
      %Ecto.Changeset{data: %Checklist{}}

  """
  def change_checklist(%Checklist{} = checklist, attrs \\ %{}) do
    Checklist.changeset(checklist, attrs)
  end
end
