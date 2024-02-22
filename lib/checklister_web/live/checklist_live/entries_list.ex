defmodule ChecklisterWeb.ChecklistLive.EntriesListComponent do
  use ChecklisterWeb, :live_component
  import ChecklisterWeb.ChecklistLive.Common, only: [build_path: 2]

  alias Checklister.Checklists.Entry

  attr :parent, :map, required: true, doc: "Entry or Checklist"

  attr :path, :list,
    required: true,
    doc: "Path from entry to parent top-level checklist to know how to update it"

  attr :timestamp, DateTime,
    required: true,
    doc: "Timestamp update is used to deep sync nested live components from the top"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="entries-list" updated-at={@timestamp |> to_string()}>
      <ul>
        <!-- Forms list for existing entries -->
        <%= for entry <- @parent.entries do %>
          <li class="mt-0 mb-0">
            <.live_component
              id={"entry-edit-#{entry.id}"}
              module={ChecklisterWeb.ChecklistLive.EntryEdit}
              entry={entry}
              path={build_path(entry, @path)}
              timestamp={@timestamp}
            />
          </li>
        <% end %>
        <!-- Form for a new entry -->
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
  def update(%{parent: parent, path: path, timestamp: timestamp}, socket) do
    socket =
      socket
      |> assign(:parent, parent)
      |> assign(:path, path)
      |> assign(:timestamp, timestamp)
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
end
