defmodule ChecklisterWeb.ChecklistLive.Edit do
  use ChecklisterWeb, :live_view

  alias Checklister.Checklists

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id} = _params, _uri, socket) do
    checklist = Checklists.get_checklist!(id)

    updated_socket =
      socket
      |> assign(:page_title, "edit")
      |> assign(:checklist, checklist)

    {:noreply, updated_socket}
  end
end
