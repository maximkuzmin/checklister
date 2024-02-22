defmodule ChecklisterWeb.ChecklistLive.Common do
  alias Checklister.Checklists.Entry
  alias Checklister.Checklists.Checklist

  @spec build_path(Entry.t() | Checklist.t(), list(String.t())) :: list(String.t())
  def build_path(%{id: id} = _entity, existing_path) do
    existing_path ++ [id]
  end
end
