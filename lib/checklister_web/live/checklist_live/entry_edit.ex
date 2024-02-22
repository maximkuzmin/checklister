defmodule ChecklisterWeb.ChecklistLive.EntryEdit do
  use ChecklisterWeb, :live_component

  alias Checklister.Checklists.Entry
  alias ChecklisterWeb.ChecklistLive.EntriesListComponent

  attr :entry, Entry, required: true

  attr :path, :list,
    required: true,
    doc: "Path from entry to parent top-level checklist to know how to update it"

  attr :timestamp, DateTime,
    required: true,
    doc: "Used to sync deep nested components from the top with update of a timestamp"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="entry-edit ml-3" updated-at={@timestamp |> to_string()}>
      <.simple_form for={@form} phx-change="validate" phx-target={@myself}>
        <small>
          <%= @entry.updated_at %>
        </small>
        <.input
          id={"entry-#{@entry.id}-name"}
          type="text"
          field={@form[:name]}
          phx-hook="SaveOnEnter"
          phx-target={@myself}
          phx-blur="update_entry"
        />
      </.simple_form>
      <%= if @expand_sublist do %>
        <.live_component
          id={"checklist-entries-list-#{@entry.id}"}
          module={EntriesListComponent}
          parent={@entry}
          path={@path}
          timestamp={@timestamp}
        />
      <% end %>
      <.button phx-click="toggle_list" phx-target={@myself}>
        Expand
      </.button>
    </div>
    """
  end

  @impl true
  def update(%{entry: entry, timestamp: timestamp} = assigns, socket) do
    changeset = entry |> Ecto.Changeset.change()
    form = changeset |> to_form()
    need_to_expand_sublist_on_start = need_to_expand_sublist?(entry)

    socket =
      %{socket | assigns: Map.merge(assigns, socket.assigns)}
      |> assign(:form, form)
      |> assign(:changeset, changeset)
      |> assign(:expand_sublist, need_to_expand_sublist_on_start)
      |> assign(:timestamp, timestamp)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"entry" => entry_params}, socket) do
    changeset =
      socket.assigns.entry
      |> Entry.changeset(entry_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "update_entry",
        _unsigned_params,
        %{assigns: %{changeset: changeset, path: path}} = socket
      ) do
    send(self(), {:update_entry, %{changes: changeset.changes, path: path}})
    {:noreply, socket}
  end

  def handle_event(
        "toggle_list",
        _unsigned_params,
        %{assigns: %{expand_sublist: expand_sublist}} = socket
      ) do
    updated_socket =
      socket
      |> assign(:expand_sublist, !expand_sublist)

    {:noreply, updated_socket}
  end

  defp need_to_expand_sublist?(%Entry{entries: entries}) do
    entries |> Enum.count() > 0
  end
end
