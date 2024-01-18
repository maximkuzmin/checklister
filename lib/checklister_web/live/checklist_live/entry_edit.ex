defmodule ChecklisterWeb.ChecklistLive.EntryEdit do
  use ChecklisterWeb, :live_component

  alias Checklister.Checklists.Entry

  @impl true
  def render(assigns) do
    ~H"""
    <div class="entry-edit">
      <.simple_form for={@form} phx-change="validate" phx-target={@myself}>
        <%= @changeset |> inspect(pretty: true) %>
        <.input
          id={"entry-#{@entry.id}-name"}
          type="text"
          field={@form[:name]}
          phx-hook="SaveOnEnter"
        />
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{entry: entry} = assigns, socket) do
    changeset = entry |> Ecto.Changeset.change()
    form = changeset |> to_form()

    socket =
      %{socket | assigns: Map.merge(assigns, socket.assigns)}
      |> assign(:form, form)
      |> assign(:changeset, changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"entry" => entry_params}, socket) do
    IO.puts("validate")
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
end
