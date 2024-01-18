defmodule ChecklisterWeb.ChecklistLive.EntriesListComponent do
  use ChecklisterWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="test-component">
        <ul>
          <li :for={entry <- @parent.entries}>
            <.live_component
              id={"entry-edit-#{entry.id}"}
              module={ChecklisterWeb.ChecklistLive.EntryEdit}
              entry={entry}
              path={build_path(entry, @path)}
            />
          </li>
        </ul>
    </div>
    """
  end

  @impl true
  def update(%{parent: parent, path: path}, socket) do
    socket =
      socket
      |> assign(:parent, parent)
      |> assign(:path, path)

    {:ok, socket}
  end

  defp build_path(%{id: id} = _entity, existing_path) do
    existing_path ++ [id]
  end
end
