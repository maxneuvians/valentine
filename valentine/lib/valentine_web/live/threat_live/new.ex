defmodule ValentineWeb.ThreatLive.New do
  use ValentineWeb, :live_view

  alias Valentine.Composer
  alias Valentine.Composer.Threat

  @context_content %{
    source: %{
      title: "Threat source",
      description: "Who or what is initiating the threat?",
      placeholder: "Enter threat source",
      examples: [
        "a malicious user",
        "an attacker with network access",
        "a compromised admin account"
      ]
    },
    prerequisite: %{
      title: "Prerequisites",
      description: "What conditions need to be met for the threat to be possible?",
      placeholder: "Enter prerequisites",
      examples: [
        "having valid credentials",
        "access to the internal network",
        "knowledge of the system architecture"
      ]
    },
    action: %{
      title: "Threat action",
      description: "What action would the threat source take?",
      placeholder: "Enter threat action",
      examples: [
        "exploit a vulnerability in the API",
        "perform a SQL injection attack",
        "intercept network traffic"
      ]
    },
    impact: %{
      title: "Threat impact",
      description:
        "What are the direct/initial impacts of the threat actions if they were to be successful?",
      placeholder: "Enter threat impact",
      examples: [
        "the actor being able to do anything the user can do",
        "the ability to modify data",
        "unnecessary and excessive costs"
      ]
    },
    asset: %{
      title: "Impacted assets",
      description: "What assets would be affected by this threat?",
      placeholder: "Enter impacted assets",
      examples: [
        "user data",
        "system configurations",
        "financial resources"
      ]
    }
  }

  @topic "threats"

  @impl true
  def mount(_params, _session, socket) do
    ValentineWeb.Endpoint.subscribe(@topic)
    {:ok,
     socket
     |> assign(:changeset, Composer.change_threat(%Threat{}))
     |> assign(:active_field, nil)
     |> assign(:threat_fields, %{
       source: "",
       prerequisite: "",
       action: "",
       impact: "",
       asset: ""
     })}
  end

  @impl true
def handle_event("validate", %{"threat" => threat_params}, socket) do
  changeset =
    %Threat{}
    |> Composer.change_threat(threat_params)
    |> Map.put(:action, :validate)

  case Composer.create_threat(threat_params) do
    {:ok, _threat} ->
      ValentineWeb.Endpoint.broadcast(@topic, "threat_created", %{})

      {:noreply,
       socket
       |> put_flash(:info, "Threat created successfully")
       |> push_navigate(to: ~p"/threats")}
      {:noreply,
       socket
       |> put_flash(:info, "Threat created successfully")
       |> push_navigate(to: ~p"/threats")}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, :changeset, changeset)}
  end
end

  @impl true
  def handle_event("show_context", %{"field" => field}, socket) do
    field = String.to_existing_atom(field)
    context = @context_content[field]

    {:noreply,
     socket
     |> assign(:active_field, field)
     |> assign(:context, context)}
  end

  @impl true
  def handle_info({:update_field, value}, socket) do
    field = socket.assigns.active_field
    changeset = Ecto.Changeset.put_change(socket.assigns.changeset, field, value)

    # Update the threat fields map
    updated_fields = Map.put(socket.assigns.threat_fields, field, value)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:threat_fields, updated_fields)}
  end

  defp render_threat_statement(fields) do
    source = if fields.source != "", do: fields.source, else: "..."
    prerequisite = if fields.prerequisite != "", do: fields.prerequisite, else: "..."
    action = if fields.action != "", do: fields.action, else: "..."
    impact = if fields.impact != "", do: fields.impact, else: "..."
    asset = if fields.asset != "", do: fields.asset, else: "..."

    "An #{source} #{prerequisite} can #{action}, which leads to #{impact} negatively impacting #{asset}"
  end
end
