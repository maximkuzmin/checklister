defmodule ChecklisterWeb.ChecklistLive.Edit do
  use ChecklisterWeb, :live_view

  alias Checklister.Checklists

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="edit-form">
      <h1>
        <%= @checklist.name %>
      </h1>
      <.live_component
        module={ChecklisterWeb.ChecklistLive.EntriesListComponent}
        id={"checklist-test-component-#{Ecto.UUID.generate()}"}
        checklist={@checklist}
        parent={@checklist}
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

    {:noreply, updated_socket}
  end

  # from
  def handle_info({:update_entry, %{path: path, changes: changes}} = params, socket) do
    checklist = Checklists.update_entry!(socket.assigns.checklist, path, changes)

    socket =
      socket
      |> assign(:checklist, checklist)

    {:noreply, socket}
  end
end
