defmodule ValentineWeb.WorkspaceLive.DataFlow.Components.ThreatStatementGeneratorComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  alias Valentine.Composer
  alias Valentine.Composer.DataFlowDiagram
  alias Valentine.Composer.Threat

  alias Phoenix.LiveView.AsyncResult

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:async_result, AsyncResult.loading())
     |> assign(:error, nil)
     |> assign(:threat, nil)
     |> assign(:usage, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.dialog
        id="threat-statement-generator-modal"
        is_backdrop
        is_show
        is_wide
        on_cancel={JS.push("toggle_generate_threat_statement")}
      >
        <:header_title>
          {gettext("Generate threat statement")}
        </:header_title>
        <:body>
          <.spinner :if={!@threat} />
          <span :if={@threat}>{Valentine.Composer.Threat.show_statement(@threat)}</span>
          <div :if={@threat} class="text-bold f4 mt-2" style="color:#cecece">
            {Valentine.Composer.Threat.stride_banner(@threat)}
          </div>
          <span :if={@error} class="text-red">{@error}</span>
        </:body>
        <:footer>
          <span class="f6">{get_caption(@usage)}</span>
          <hr />
          <.button :if={@threat} is_primary phx-click="save" phx-target={@myself}>
            {gettext("Save")}
          </.button>
          <.button :if={@threat} phx-click="generate_again" phx-target={@myself}>
            {gettext("Generate another")}
          </.button>
          <.button phx-click="toggle_generate_threat_statement">{gettext("Cancel")}</.button>
        </:footer>
      </.dialog>
    </div>
    """
  end

  @impl true
  def handle_async(:running_llm, async_fun_result, socket) do
    result = socket.assigns.async_result

    case async_fun_result do
      {:ok, data} ->
        {:noreply, socket |> assign(:async_result, AsyncResult.ok(result, data))}

      {:error, reason} ->
        {:noreply, socket |> assign(:async_result, AsyncResult.failed(result, reason))}
    end
  end

  @impl true
  def handle_event("generate_again", _, socket) do
    send_update(self(), socket.assigns.myself, %{
      id: socket.assigns.id,
      element_id: socket.assigns.element_id,
      error: nil,
      threat: nil,
      workspace_id: socket.assigns.workspace_id
    })

    {:noreply, socket |> assign(:threat, nil)}
  end

  @impl true
  def handle_event("save", _, socket) do
    case socket.assigns.threat do
      nil ->
        {:noreply, socket |> assign(:error, gettext("No threat statement generated"))}

      _ ->
        {:ok, threat} =
          socket.assigns.threat
          |> Composer.change_threat(%{
            tags: [gettext("AI generated")],
            workspace_id: socket.assigns.workspace_id
          })
          |> Valentine.Repo.insert()

        send(
          self(),
          {:update_metadata,
           %{
             "id" => socket.assigns.element_id,
             "field" => "linked_threats",
             "checked" => threat.id,
             "value" => 0
           }}
        )

        send(self(), {:toggle_generate_threat_statement, nil})

        {:noreply, socket |> assign(:threat, nil)}
    end
  end

  @impl true
  def update(%{chat_complete: data}, socket) do
    case Jason.decode(data.content) do
      {:ok, json} ->
        alias Valentine.Composer.Threat

        threat =
          %Threat{
            threat_source: json["threat_source"],
            prerequisites: json["prerequisites"],
            threat_action: json["threat_action"],
            threat_impact: json["threat_impact"],
            impacted_goal: json["impacted_goal"],
            impacted_assets: json["impacted_assets"],
            stride: json["stride"] |> Enum.map(&String.to_existing_atom/1)
          }

        {:ok, socket |> assign(:threat, threat)}

      _ ->
        {:ok, socket |> assign(:error, gettext("Error decoding response"))}
    end
  end

  @impl true
  def update(%{usage_update: usage}, socket) do
    {:ok, socket |> assign(:usage, usage)}
  end

  @impl true
  def update(assigns, socket) do
    chain =
      %{
        llm:
          ChatOpenAI.new!(
            Map.merge(
              %{
                json_response: true,
                json_schema: json_schema(),
                callbacks: [llm_handler(self(), socket.assigns.myself)]
              },
              llm_params()
            )
          ),
        callbacks: [llm_handler(self(), socket.assigns.myself)]
      }
      |> LLMChain.new!()
      |> LLMChain.add_messages([
        Message.new_system!(system_prompt()),
        Message.new_user!(user_prompt(assigns.element_id, assigns.workspace_id))
      ])

    {:ok,
     socket
     |> assign(assigns)
     |> start_async(:running_llm, fn ->
       case LLMChain.run(chain) do
         {:error, %LLMChain{} = _chain, reason} ->
           {:error, reason}

         _ ->
           :ok
       end
     end)}
  end

  defp json_schema() do
    %{
      name: "threat_generator_response",
      strict: true,
      schema: %{
        type: "object",
        properties: %{
          threat_source: %{
            type: "string",
            description:
              "The entity taking action. This field is part of a sentence, do not capitalize the first letter or end with punctuation."
          },
          prerequisites: %{
            type: "string",
            description:
              "Conditions or requirements that must be met for a threat source's action to be viable. This field is part of a sentence, do not capitalize the first letter or end with punctuation."
          },
          threat_action: %{
            type: "string",
            description:
              "The action being performed by the threat source. This field is part of a sentence, do not capitalize the first letter or end with punctuation."
          },
          threat_impact: %{
            type: "string",
            description:
              "The direct impact of a successful threat action. This field is part of a sentence, do not capitalize the first letter or end with punctuation."
          },
          impacted_goal: %{
            type: ["array", "null"],
            description:
              "The goal that is negatively impacted by the threat action. This field is part of a sentence, do not capitalize the first letter or end with punctuation.",
            items: %{
              type: "string"
            }
          },
          impacted_assets: %{
            type: "array",
            description:
              "The assets affected by a successful threat action. This field is part of a sentence, do not capitalize the first letter or end with punctuation.",
            items: %{
              type: "string"
            }
          },
          stride: %{
            type: "array",
            description:
              "The STRIDE model is a model used to identify different types of threats in a system. STRIDE stands for Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, and Elevation of privilege. Select the STRIDE categories that apply to the threat statement.",
            items: %{
              type: "string",
              enum: [
                "spoofing",
                "tampering",
                "repudiation",
                "information_disclosure",
                "denial_of_service",
                "elevation_of_privilege"
              ]
            }
          }
        },
        required: [
          "threat_source",
          "prerequisites",
          "threat_action",
          "threat_impact",
          "impacted_goal",
          "impacted_assets",
          "stride"
        ],
        additionalProperties: false
      }
    }
  end

  defp llm_handler(lc_pid, myself) do
    %{
      on_message_processed: fn _chain, %Message{} = data ->
        send_update(lc_pid, myself, chat_complete: data)
      end,
      on_llm_token_usage: fn _model, usage ->
        send_update(lc_pid, myself, usage_update: usage)
      end
    }
  end

  defp llm_params() do
    cond do
      Application.get_env(:langchain, :openai_key) ->
        %{
          model: "gpt-4o-mini",
          max_completion_tokens: 100_000
        }

      Application.get_env(:langchain, :azure_openai_endpoint) ->
        %{
          endpoint: Application.get_env(:langchain, :azure_openai_endpoint),
          api_key: Application.get_env(:langchain, :azure_openai_key),
          max_completion_tokens: 100_000
        }

      true ->
        %{}
    end
  end

  defp system_prompt() do
    """
    You are an expert in threat modeling that is helping to generate novel threats for a given system.
    To effectively generate a threat statement, you need to understand the system's architecture, data flows, and assumptions.
    Threat statements are generated using a threat grammar. The grammar looks like this:application

    A/An [threat source] [prerequisites] can [threat action] which leads to [threat impact], resulting in reduced [impacted goal], negatively impacting [impacted assets].

    Where:

    1. Threat source:

    The entity taking action. For example:

    threat actor (a useful default).
    internet-based threat actor.
    internal or external actor.

    2. Prerequisites:

    Conditions or requirements that must be met for a threat source's action to be viable. For example:

    With access to another user's token.
    Who has administrator access.
    With user permissions.

    If there are no prerequisites, that might be a signal to decompose the threat into several statements. These would include multiple prerequisites for the same threat source.

    3. Threat action:

    The action being performed by the threat source. For example:

    Spoof another user.
    Tamper with data stored in the database.
    Make thousands of concurrent requests.

    4. Threat impact:

    The direct impact of a successful threat action. For example:

    Unauthorized access to the user's bank account information.
    Modifying the username for the all-time high score.
    A web application being unable to handle other user requests.

    5. Impacted goal:

    The goal that is negatively impacted by the threat action. For example:

    availability
    return of investment
    integrity
    confidentiality

    6. Impacted assets:

    The assets affected by a successful threat action. For example:

    User banking data.
    Video game high score list.
    The web application.

    Here are some sample statements:

    An [internet-based threat actor][with access to another user's token] can [spoof another user] which leads to [viewing the user's bank account information], negatively impacting [user banking data]

    An [internal threat actor] [who has administrator access] can [tamper with data stored in the database] which leads to [modifying the username for the all-time high score], negatively impacting [the video game high score list]

    An [internet-based threat actor] [with user permissions] can [make thousands of concurrent requests] which leads to [the application being unable to handle other user requests], negatively impacting [the web application’s responsiveness to valid requests].

    The statements must then also be categorized using the STRIDE model.

    Also, threats should be realistic and relevant to the system being modeled, for example it is unlikely that a threat actor would be able to physically access a server in a data center to tamper with it.
    Similarly, a threat actor is not able to break current cryptographic standards to decrypt data.

    Assume that a threat actor has the ability to perform actions that are within the realm of possibility, but not necessarily easy to achieve.
    A threat actor may be:

    - Cybercriminals who are often financially motivated.
    - Hacktivists who are often ideologically motivated.
    - Terrorist groups who are often motivated by ideological violence.
    - Thrill-seekers who are often motivated by satisfaction.
    - Insider threat actors who are often motivated by discontent.

    Please do not include:

      - Nation state cyber threat actors who are often geopolitically motivated.

    VERY IMPORTANT: REVIEW THE STATEMENT TO SEE IF IT MAKES GRAMMATICAL AND LOGICAL SENSE AND DO NOT REUSE PREVIOUS STATEMENTS. FOCUS ON THREATS IDENTIFIED BY THE OWASP TOP 10
    """
  end

  defp user_prompt(element_id, workspace_id) do
    dfd = DataFlowDiagram.get(workspace_id, false)

    workspace =
      Composer.get_workspace!(
        workspace_id,
        [:application_information, :architecture, :assumptions, :threats]
      )

    prompt = """
    You are generating a threat statement for the application with the following information using the threat grammar described in the system prompt.

    Application information:
    #{if workspace.application_information, do: workspace.application_information.content, else: "No content available"}

    Architecture:
    #{if workspace.architecture, do: workspace.architecture.content, else: "No content available"}

    Assumptions:
    #{if workspace.assumptions, do: workspace.assumptions |> Enum.map(&("START:" <> &1.content <> "END\n")), else: "No content available"}

    Already existing threat statements:
    #{if workspace.threats, do: workspace.threats |> Enum.map(&("START:" <> Valentine.Composer.Threat.show_statement(&1) <> "END\n")), else: "No content available"}

    JSON representation of the data flow diagram:
      Nodes: #{Jason.encode!(dfd.nodes)}
      Edges: #{Jason.encode!(dfd.edges)}

    From within the data flow diagram, you are focusing on the element with the ID: #{element_id}.

    """

    Regex.replace(~r{<img[^>]*>}, prompt, "")
  end

  defp get_caption(usage) do
    base = gettext("Mistakes are possible. Review output carefully before use.")

    if usage do
      # In cost $0.150 / 1M input tokens
      # Out cost $0.600 / 1M output tokens

      # Cost rounded to cents
      cost = Float.round(usage.input * 0.00000015 + usage.output * 0.0000006, 2)

      base <>
        gettext(" Current token usage: (In: %{in}, Out: %{out}, Cost: $%{cost})",
          in: usage.input,
          out: usage.output,
          cost: cost
        )
    else
      base
    end
  end
end
