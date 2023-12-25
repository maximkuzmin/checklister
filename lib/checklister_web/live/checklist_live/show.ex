defmodule ChecklisterWeb.ChecklistLive.Show do
  use ChecklisterWeb, :live_view

  alias Checklister.Checklists

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:checklist, Checklists.get_checklist!(id))}
  end

  defp page_title(:show), do: "Show Checklist"
  defp page_title(:edit), do: "Edit Checklist"
end
