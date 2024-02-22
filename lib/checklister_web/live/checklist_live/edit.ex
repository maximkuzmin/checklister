defmodule ChecklisterWeb.ChecklistLive.Edit do
  use ChecklisterWeb, :live_view

  alias Checklister.Checklists

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    updated_socket = socket |> add_new_timestamp()

    {:ok, updated_socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="edit-form">
      <h1>
        <%= @checklist.name %>
        <%= @checklist.updated_at %>
      </h1>
      <.live_component
        module={ChecklisterWeb.ChecklistLive.EntriesListComponent}
        id={"checklist-entries-list-component-#{@checklist.id}"}
        parent={@checklist}
        timestamp={@timestamp}
        path={[]}
      />
    </div>
    """
  end

  @impl Phoenix.LiveView
  @spec handle_params(map(), any(), map()) :: {:noreply, map()}
  def handle_params(%{"id" => id} = _params, _uri, socket) do
    checklist =
      id
      |> Checklists.get_checklist!()

    updated_socket =
      socket
      |> assign(:page_title, "edit")
      |> assign(:checklist, checklist)
      |> add_new_timestamp()

    {:noreply, updated_socket}
  end

  @impl true
  def handle_info(
        {:update_entry, %{path: path, changes: changes}},
        %{assigns: %{checklist: checklist}} = socket
      ) do
    checklist = Checklists.update_entry!(checklist, path, changes)
    checklist = Checklists.get_checklist!(checklist.id)

    updated_socket =
      socket
      |> assign(:checklist, checklist)
      |> add_new_timestamp()

    {:noreply, updated_socket}
  end

  def handle_info(
        {:add_entry, %{path: path, changes: changes}},
        %{assigns: %{checklist: checklist}} = socket
      ) do
    checklist = Checklists.add_entry!(checklist, path, changes)

    updated_socket =
      socket
      |> assign(:checklist, checklist)
      |> add_new_timestamp()

    {:noreply, updated_socket}
  end

  defp add_new_timestamp(socket) do
    socket
    |> assign(:timestamp, DateTime.utc_now())
  end
end
