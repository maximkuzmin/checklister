defmodule ChecklisterWeb.ChecklistLive.FormComponent do
  use ChecklisterWeb, :live_component

  alias Checklister.Checklists

  alias Checklister.Checklists.Entry

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @id %></h1>
      <.header>
        <%= @title %>
        <:subtitle>
          Use this form to manage checklist records in your database.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="checklist-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:is_template]} type="checkbox" label="Is template" />
        <:actions>
          <.button phx-disable-with="Not saving">Unsave checklist</.button>
        </:actions>
        <:actions>
          <.button phx-disable-with="Saving...">Save Checklist</.button>
        </:actions>

        <.button phx-click="add_entry">Add entry</.button>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{checklist: checklist} = assigns, socket) do
    changeset = Checklists.change_checklist(checklist)
    new_entry = Ecto.Changeset.change(%Entry{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:new_entry_form, to_form(new_entry))
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"checklist" => checklist_params} = _params, socket) do
    changeset =
      socket.assigns.checklist
      |> Checklists.change_checklist(checklist_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"checklist" => checklist_params}, socket) do
    save_checklist(socket, socket.assigns.action, checklist_params)
  end

  defp save_checklist(socket, :edit, checklist_params) do
    socket.assigns.checklist
    |> Checklists.update_checklist(checklist_params)
    |> case do
      {:ok, checklist} ->
        notify_parent({:saved, checklist})

        {:noreply,
         socket
         |> put_flash(:info, "Checklist updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_checklist(socket, :new, checklist_params) do
    checklist_params
    |> Checklists.create_checklist()
    |> case do
      {:ok, checklist} ->
        notify_parent({:saved, checklist})

        {:noreply,
         socket
         |> put_flash(:info, "Checklist created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
