defmodule ValentineWeb.ThreatLive.ThreatFormComponent do
  use ValentineWeb, :live_component

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

  @impl true
  def update(assigns, socket) do
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

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form :let={f} for={@changeset} phx-change="validate" action={~p"/threats"}>
        <div class="space-y-6 bg-white">
          <div class="border rounded-lg p-4">
            <%= if @changeset.action do %>
              <div class="alert alert-danger">
                <p>Oops, something went wrong! Please check the errors below.</p>
              </div>
            <% end %>

            <p class="mb-4 text-sm text-gray-600">
              Start by clicking ANY field you like and work from there...
            </p>

            <div class="flex flex-wrap items-center gap-2">
              <input
                type="hidden"
                value={Ecto.Changeset.get_field(@changeset, :source)}
                name="threat[source]"
              />
              <.error :if={@changeset.action && f.errors[:source]}>
                <%= translate_error(f.errors[:source]) %>
              </.error>

              <input
                type="hidden"
                value={Ecto.Changeset.get_field(@changeset, :prerequisite)}
                name="threat[prerequisite]"
              />
              <.error :if={@changeset.action && f.errors[:prerequisite]}>
                <%= translate_error(f.errors[:prerequisite]) %>
              </.error>

              <input
                type="hidden"
                value={Ecto.Changeset.get_field(@changeset, :action)}
                name="threat[action]"
              />
              <.error :if={@changeset.action && f.errors[:action]}>
                <%= translate_error(f.errors[:action]) %>
              </.error>

              <input
                type="hidden"
                value={Ecto.Changeset.get_field(@changeset, :impact)}
                name="threat[impact]"
              />
              <.error :if={@changeset.action && f.errors[:impact]}>
                <%= translate_error(f.errors[:impact]) %>
              </.error>

              <input
                type="hidden"
                value={Ecto.Changeset.get_field(@changeset, :asset)}
                name="threat[asset]"
              />
              <.error :if={@changeset.action && f.errors[:asset]}>
                <%= translate_error(f.errors[:asset]) %>
              </.error>

              <span>A</span>

              <.live_component
                module={ValentineWeb.ThreatLive.ThreatFieldComponent}
                id="source-field"
                field={:source}
                placeholder="threat source"
                changeset={@changeset}
              />

              <.live_component
                module={ValentineWeb.ThreatLive.ThreatFieldComponent}
                id="prerequisite-field"
                field={:prerequisite}
                placeholder="prerequisite"
                changeset={@changeset}
              />

              <span>can</span>

              <.live_component
                module={ValentineWeb.ThreatLive.ThreatFieldComponent}
                id="action-field"
                field={:action}
                placeholder="threat action"
                changeset={@changeset}
              />

              <span>which leads to</span>

              <.live_component
                module={ValentineWeb.ThreatLive.ThreatFieldComponent}
                id="impact-field"
                field={:impact}
                placeholder="threat impact"
                changeset={@changeset}
              />

              <span>negatively impacting</span>

              <.live_component
                module={ValentineWeb.ThreatLive.ThreatFieldComponent}
                id="asset-field"
                field={:asset}
                placeholder="impacted assets"
                changeset={@changeset}
              />
            </div>
          </div>
        </div>

        <%= if @active_field do %>
          <.live_component
            module={ValentineWeb.ThreatLive.ContextHelpComponent}
            id="context-help"
            form={f}
            active_field={@active_field}
            title={@context.title}
            description={@context.description}
            placeholder={@context.placeholder}
            examples={@context.examples}
            show_full_examples={false}
            mitigation_inputs={[
              {:source, "Threat source"},
              {:prerequisite, "Prerequisite"},
              {:action, "Threat action"}
            ]}
            prioritization_inputs={[
              {:impact, "Threat impact"},
              {:goal, "Impacted goal"},
              {:assets, "Impacted assets"}
            ]}
          />
        <% end %>

        <:actions>
          <.button>Save Threat</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"threat" => threat_params}, socket) do
    changeset = Composer.change_threat(socket.assigns.threat, threat_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
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
