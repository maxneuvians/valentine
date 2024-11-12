defmodule ValentineWeb.WorkspaceLive.Threat.Show do
  use ValentineWeb, :live_view

  alias Valentine.Composer
  alias Valentine.Composer.Threat

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    ValentineWeb.Endpoint.subscribe("workspace_" <> workspace_id)

    {:ok,
     socket
     |> assign(:workspace_id, workspace_id)
     |> assign(:threat, Composer.change_threat(%Threat{}))
     |> assign(:active_field, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"workspace_id" => workspace_id} = _params) do
    socket
    |> assign(:page_title, "Create new threat statement")
    |> assign(:workspace_id, workspace_id)
    |> assign(:threat, %Threat{workspace_id: workspace_id})
    |> assign(:changeset, Composer.change_threat(%Threat{workspace_id: workspace_id}))
  end

  defp apply_action(socket, :edit, %{"id" => id, "workspace_id" => workspace_id} = _params) do
    threat = Composer.get_threat!(id)

    socket
    |> assign(:page_title, "Edit threat statement")
    |> assign(:workspace_id, workspace_id)
    |> assign(:threat, threat)
    |> assign(:changeset, Composer.change_threat(threat))
  end

  def handle_event("validate", %{"threat" => threat_params}, socket) do
    if socket.assigns.threat.id do
      update_existing_threat(threat_params, socket)
    else
      create_new_threat(threat_params, socket)
    end
  end

  @impl true
  def handle_event("show_context", %{"field" => field}, socket) do
    field = String.to_existing_atom(field)
    context = ValentineWeb.WorkspaceLive.Threat.Components.StatementExamples.content(field)

    {:noreply,
     socket
     |> assign(:active_field, field)
     |> assign(:context, context)}
  end

  @impl true
  def handle_info({:update_field, value}, socket) do
    field = socket.assigns.active_field
    changeset = Ecto.Changeset.put_change(socket.assigns.changeset, field, value)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  defp update_existing_threat(threat_params, socket) do
    case Composer.update_threat(socket.assigns.threat, threat_params) do
      {:ok, threat} ->
        broadcast_threat_change(threat, "threat_updated")

        {:noreply,
         socket
         |> put_flash(:info, "Threat updated successfully")
         |> push_navigate(to: ~p"/workspaces/#{threat.workspace_id}/threats")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp create_new_threat(threat_params, socket) do
    case Composer.create_threat(threat_params) do
      {:ok, threat} ->
        broadcast_threat_change(threat, "threat_created")

        {:noreply,
         socket
         |> put_flash(:info, "Threat created successfully")
         |> push_navigate(to: ~p"/workspaces/#{threat.workspace_id}/threats")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp broadcast_threat_change(threat, event) do
    ValentineWeb.Endpoint.broadcast(
      "workspace_" <> threat.workspace_id,
      event,
      %{}
    )
  end
end
