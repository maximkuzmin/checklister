defmodule ChecklisterWeb.ChecklistLive.EntriesListComponent do
  use ChecklisterWeb, :live_component

  alias Checklister.Checklists.Entry

  attr :parent, :any, required: true
  attr :path, :list, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="test-component">
      <ul>
        <li :for={entry <- @parent.entries} class="mt-0 mb-0">
          <.live_component
            id={"entry-edit-#{entry.id}"}
            module={ChecklisterWeb.ChecklistLive.EntryEdit}
            entry={entry}
            path={build_path(entry, @path)}
          />
        </li>
        <li>
          <.simple_form
            for={@form}
            id={"new-entry-for-#{@parent.id}"}
            phx-change="validate"
            phx-target={@myself}
          >
            <.input
              id={"new-entry-for-#{@parent.id}-name"}
              type="text"
              field={@form[:name]}
              phx-hook="AddEntry"
            />
          </.simple_form>
        </li>
      </ul>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"entry" => entry_params}, socket) do
    changeset =
      %Entry{}
      |> Entry.changeset(entry_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event(
        "add_entry",
        _unsigned_params,
        %{assigns: %{changeset: changeset, path: path}} = socket
      ) do
    changes = changeset.changes
    # ask top-level live-view to actually update checklist
    send(self(), {:add_entry, %{path: path, changes: changes}})

    # clear form to make it ready for a new record
    socket =
      socket
      |> assign_new_entry_form()

    {:noreply, socket}
  end

  @impl true
  def update(%{parent: parent, path: path}, socket) do
    socket =
      socket
      |> assign(:parent, parent)
      |> assign(:path, path)
      |> assign_new_entry_form()

    {:ok, socket}
  end

  defp assign_new_entry_form(socket) do
    changeset = Ecto.Changeset.change(%Entry{})
    form = to_form(changeset)

    socket
    |> assign(:form, form)
    |> assign(:changeset, changeset)
  end

  defp build_path(%{id: id} = _entity, existing_path) do
    existing_path ++ [id]
  end
end
