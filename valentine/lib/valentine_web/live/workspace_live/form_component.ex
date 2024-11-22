defmodule ValentineWeb.WorkspaceLive.FormComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        id="workspaces-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.dialog
          id="workspace-modal"
          is_backdrop
          is_show
          is_wide
          on_cancel={JS.patch(~p"/workspaces")}
        >
          <:header_title>
            <%= if @workspace.id do %>
              Edit Workspace
            <% else %>
              New Workspace
            <% end %>
          </:header_title>
          <:body>
            <.text_input form={f} field={:name} class="mt-2" is_full_width is_form_control />
          </:body>
          <:footer>
            <.button is_primary is_submit phx-disable-with="Saving...">
              Save Workspace
            </.button>
            <.button phx-click={cancel_dialog("workspace-modal")}>Cancel</.button>
          </:footer>
        </.dialog>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{workspace: workspace} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Composer.change_workspace(workspace))}
  end

  @impl true
  def handle_event("validate", %{"workspace" => workspace_params}, socket) do
    changeset = Composer.change_workspace(socket.assigns.workspace, workspace_params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"workspace" => workspace_params}, socket) do
    save_workspace(socket, socket.assigns.action, workspace_params)
  end

  defp save_workspace(socket, :edit, workspace_params) do
    case Composer.update_workspace(socket.assigns.workspace, workspace_params) do
      {:ok, workspace} ->
        notify_parent({:saved, workspace})

        {:noreply,
         socket
         |> put_flash(:info, "Workspace updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_workspace(socket, :new, workspace_params) do
    case Composer.create_workspace(workspace_params) do
      {:ok, workspace} ->
        notify_parent({:saved, workspace})

        {:noreply,
         socket
         |> put_flash(:info, "Workspace created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
