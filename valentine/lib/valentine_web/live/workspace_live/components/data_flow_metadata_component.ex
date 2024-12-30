defmodule ValentineWeb.WorkspaceLive.Components.DataFlowMetadataComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  def update(assigns, socket) do
    dfd = Valentine.Composer.DataFlowDiagram.get(assigns.workspace_id)

    element =
      cond do
        String.starts_with?(assigns.element_id, "node") -> dfd.nodes[assigns.element_id]
        String.starts_with?(assigns.element_id, "edge") -> dfd.edges[assigns.element_id]
        true -> nil
      end

    {:ok, socket |> assign(:element, element)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.box :if={@element} class="p-4 mt-2">
        <h3>Properties</h3>
        <div class="clearfix">
          <div class="float-left col-4 p-2">
            <.text_input
              name="name"
              placeholder="Set a name"
              input_id="data-element-name"
              is_form_control
              autocomplete="off"
              value={@element["data"]["label"]}
              phx-keyup="update_metadata"
              phx-value-id={@element["data"]["id"]}
              phx-value-field="label"
              is_full_width
              class="mb-4"
            />
            <.textarea
              name="description"
              placeholder="Add a description..."
              input_id="data-element-description"
              is_full_width
              rows="3"
              is_form_control
              value={@element["data"]["description"]}
              phx-keyup="update_metadata"
              phx-value-id={@element["data"]["id"]}
              phx-value-field="description"
              class="mb-4"
            />
            <.checkbox
              name="out-of-scope"
              input_id="data-element-out-of-scope"
              checked={@element["data"]["out_of_scope"] == "true"}
              phx-click="update_metadata"
              phx-value-id={@element["data"]["id"]}
              phx-value-field="out_of_scope"
            >
              <:label>
                Out of scope
              </:label>
            </.checkbox>
          </div>
          <div class="float-left col-4 p-2 pl-2">
            <label>Data features</label>
            <.action_menu
              is_dropdown_caret
              id="data-element-data-tags"
              class="mb-4 data-element-action-menu"
            >
              <:toggle>
                Select data features
                <%= if is_list(@element["data"]["data_tags"]) && length(@element["data"]["data_tags"]) > 0 do %>
                  <.counter>
                    {length(@element["data"]["data_tags"])}
                  </.counter>
                <% end %>
              </:toggle>
              <.action_list is_multiple_select>
                <%= for {section, values} <- data_options(@element["data"]["type"]) do %>
                  <.action_list_section_divider>
                    <:title>{Phoenix.Naming.humanize(section)}</:title>
                  </.action_list_section_divider>
                  <%= for value <- values do %>
                    <.action_list_item
                      field={:data_tags}
                      checked_value={value}
                      is_multiple_select
                      phx-click="update_metadata"
                      phx-value-id={@element["data"]["id"]}
                      phx-value-field="data_tags"
                      phx-value-checked={value}
                      is_selected={value in @element["data"]["data_tags"]}
                    >
                      {Phoenix.Naming.humanize(value)}
                    </.action_list_item>
                  <% end %>
                <% end %>
              </.action_list>
            </.action_menu>
            <label>Security features</label>
            <.action_menu
              is_dropdown_caret
              id="data-element-security-tags"
              class="mb-4 data-element-action-menu"
            >
              <:toggle>
                Select security features
                <%= if is_list(@element["data"]["security_tags"]) && length(@element["data"]["security_tags"]) > 0 do %>
                  <.counter>
                    {length(@element["data"]["security_tags"])}
                  </.counter>
                <% end %>
              </:toggle>
              <.action_list is_multiple_select>
                <%= for {section, values} <- security_options(@element["data"]["type"]) do %>
                  <.action_list_section_divider>
                    <:title>{Phoenix.Naming.humanize(section)}</:title>
                  </.action_list_section_divider>
                  <%= for value <- values do %>
                    <.action_list_item
                      field={:security_tags}
                      checked_value={value}
                      is_multiple_select
                      phx-click="update_metadata"
                      phx-value-id={@element["data"]["id"]}
                      phx-value-field="security_tags"
                      phx-value-checked={value}
                      is_selected={value in @element["data"]["security_tags"]}
                    >
                      {Phoenix.Naming.humanize(value)}
                    </.action_list_item>
                  <% end %>
                <% end %>
              </.action_list>
            </.action_menu>
            <label>Technology features</label>
            <.action_menu
              is_dropdown_caret
              id="data-element-technology-tags"
              class="data-element-action-menu"
            >
              <:toggle>
                Select technology features
                <%= if is_list(@element["data"]["technology_tags"]) && length(@element["data"]["technology_tags"]) > 0 do %>
                  <.counter>
                    {length(@element["data"]["technology_tags"])}
                  </.counter>
                <% end %>
              </:toggle>
              <.action_list is_multiple_select>
                <%= for {section, values} <- technology_options(@element["data"]["type"]) do %>
                  <.action_list_section_divider>
                    <:title>{Phoenix.Naming.humanize(section)}</:title>
                  </.action_list_section_divider>
                  <%= for value <- values do %>
                    <.action_list_item
                      field={:technology_tags}
                      checked_value={value}
                      is_multiple_select
                      phx-click="update_metadata"
                      phx-value-id={@element["data"]["id"]}
                      phx-value-field="technology_tags"
                      phx-value-checked={value}
                      is_selected={value in @element["data"]["technology_tags"]}
                    >
                      {Phoenix.Naming.humanize(value)}
                    </.action_list_item>
                  <% end %>
                <% end %>
              </.action_list>
            </.action_menu>
          </div>
          <div class="float-left col-4 p-2 pl-4">
            <div class="mb-2">
              <label>
                More information about {Phoenix.Naming.humanize(@element["data"]["type"])}
              </label>
            </div>
            {node_description(@element["data"]["type"]) |> Phoenix.HTML.raw()}
          </div>
        </div>
      </.box>
    </div>
    """
  end

  defp data_options(type) do
    generic_options = %{
      "customer_data" => ["stores_customer_data", "processes_customer_data"],
      "sensitive_data" => ["stores_sensitive_data", "processes_sensitive_data"],
      "personal_identifiable_information" => [
        "stores_personal_identifiable_information",
        "processes_personal_identifiable_information"
      ]
    }

    specific_options =
      case type do
        "actor" ->
          %{}

        "datastore" ->
          %{
            "logs,_credentials,_encryption" => [
              "stores_logs",
              "stores_credentials",
              "data_is_signed",
              "data_is_encrypted"
            ]
          }

        "edge" ->
          %{}

        "process" ->
          %{"data_exchange_format" => ["json", "xml", "csv", "thirft", "grpc"]}

        "trust_boundary" ->
          %{}

        _ ->
          %{}
      end

    Map.merge(generic_options, specific_options)
  end

  defp security_options(type) do
    generic_options = %{
      "authorization" => ["oauth", "jwt", "saml", "other_authorization", "no_authroization"],
      "authentication" => ["password", "2fa", "mfa", "other_authentication", "no_authentication"],
      "secrets_and_sessions" => ["implements_secrets_management", "implements_session_management"]
    }

    specific_options =
      case type do
        "actor" ->
          %{}

        "datastore" ->
          %{}

        "edge" ->
          %{}

        "process" ->
          %{}

        "trust_boundary" ->
          %{}

        _ ->
          %{}
      end

    Map.merge(generic_options, specific_options)
  end

  defp technology_options(type) do
    generic_options = %{
      "other_features" => ["third party software", "file uploads", "admin_dashboard/console"]
    }

    specific_options =
      case type do
        "actor" ->
          %{"frontend_frameworks" => ["react", "angular", "vue", "svelte", "other_frontend"]}

        "datastore" ->
          %{
            "data storage and querying" => [
              "sql",
              "nosql",
              "data warehouse",
              "data lake",
              "emr",
              "other_storage"
            ]
          }

        "edge" ->
          %{}

        "process" ->
          %{
            "architecture" => ["monolithic", "microservices", "serverless"],
            "language" => [
              "ruby",
              "elixir",
              "python",
              "java",
              "go",
              "javascript",
              "other_language"
            ],
            "os" => ["linux", "windows", "macos", "other"],
            "backend_frameworks" => [
              "rails",
              "phoenix",
              "django",
              "flask",
              "spring",
              "express",
              "other_backend"
            ]
          }

        "trust_boundary" ->
          %{}

        _ ->
          %{}
      end

    Map.merge(generic_options, specific_options)
  end

  defp node_description(type) do
    case type do
      "actor" ->
        """
        <p>
          An actor represents a user or system that interacts with the system. Actors can be internal or external to the system.
        </p>
        """

      "datastore" ->
        """
        <p>
          A datastore represents a system that stores data. Datastores can be databases, file systems, or any other system that stores data.
        </p>
        """

      "edge" ->
        """
        <p>
          An edge represents a connection between two nodes. Edges can represent data flow, control flow, or any other type of connection between nodes.
        </p>
        """

      "process" ->
        """
        <p>
          A process represents a system that processes data. Processes can be services, functions, or any other system that processes data.
        </p>
        """

      "trust_boundary" ->
        """
        <p>
          A trust boundary represents a boundary within the system that separates trusted and untrusted components. Trust boundaries are used to protect the system from external threats.
        </p>
        """

      _ ->
        """
        <p>
          No description available for this node type.
        </p>
        """
    end
  end
end
