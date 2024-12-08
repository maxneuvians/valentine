defmodule ValentineWeb.WorkspaceLive.Components.ChatComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  alias Valentine.Composer
  alias Phoenix.LiveView.AsyncResult

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message
  alias LangChain.MessageDelta

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       :chain,
       %{
         llm:
           ChatOpenAI.new!(%{
             model: "gpt-4o-mini",
             max_completion_tokens: 100_000,
             stream: true,
             stream_options: %{include_usage: true},
             callbacks: [llm_handler(self(), socket.assigns.myself)]
           }),
         callbacks: [llm_handler(self(), socket.assigns.myself)]
       }
       |> LLMChain.new!()
     )
     |> assign(:usage, nil)
     |> assign(:async_result, %AsyncResult{})}
  end

  def render(assigns) do
    ~H"""
    <div class="chat_pane">
      <div class="chat_messages" phx-hook="ChatScroll" id="chat-messages">
        <%= if length(@chain.messages) > 0 do %>
          <ul>
            <li
              :for={message <- @chain.messages}
              :if={message.role != :system}
              class="chat_message"
              data-role={message.role}
            >
              <div class="chat_message_role"><%= role(message.role) %></div>
              <%= format_msg(message.content) %>
            </li>
            <li :if={@chain.delta} class="chat_message" data-role={@chain.delta.role}>
              <div class="chat_message_role"><%= role(@chain.delta.role) %></div>
              <%= format_msg(@chain.delta.content) %>
            </li>
          </ul>
        <% else %>
          <.blankslate class="mt-4">
            <:octicon name="dependabot-24" />
            <h3>Ask AI Assistant</h3>
            <p><%= tag_line(@active_module, @active_action) %></p>
          </.blankslate>
        <% end %>
      </div>

      <div class="chat_input_container">
        <.textarea
          placeholder="Ask AI Assistant."
          is_full_width
          rows="3"
          caption={get_caption(@usage)}
          is_form_control
          phx-hook="EnterSubmitHook"
          id="chat_input"
        />
      </div>
    </div>
    """
  end

  def update(%{chat_response: data}, socket) do
    chain =
      socket.assigns.chain
      |> LLMChain.apply_delta(data)

    {:ok,
     socket
     |> assign(chain: chain)}
  end

  def update(%{usage_update: usage}, socket) do
    {:ok,
     socket
     |> assign(usage: usage)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def handle_async(:running_llm, async_fun_result, socket) do
    result = socket.assigns.async_result

    case async_fun_result do
      {:ok, _} ->
        {:noreply, socket |> assign(:async_result, AsyncResult.ok(result, "initial result"))}

      {:error, reason} ->
        {:noreply, socket |> assign(:async_result, AsyncResult.failed(result, reason))}
    end
  end

  def handle_event("chat_submit", %{"value" => value}, socket) do
    %{active_module: active_module, active_action: active_action, workspace_id: workspace_id} =
      socket.assigns

    chain =
      socket.assigns.chain
      |> LLMChain.add_messages([
        Message.new_system!(system_prompt(active_module, active_action, workspace_id)),
        Message.new_user!(value)
      ])

    {:noreply,
     socket
     |> assign(chain: chain)
     |> run_chain()}
  end

  def run_chain(socket) do
    chain = socket.assigns.chain

    socket
    |> assign(:async_result, AsyncResult.loading())
    |> start_async(:running_llm, fn ->
      case LLMChain.run(chain) do
        {:error, %LLMChain{} = _chain, reason} ->
          {:error, reason}

        _ ->
          :ok
      end
    end)
  end

  defp get_caption(usage) do
    base = "Mistakes are possible. Review output carefully before use."

    if usage do
      # In cost $0.150 / 1M input tokens
      # Out cost $0.600 / 1M output tokens

      # Cost rounded to cents
      cost = Float.round(usage.input * 0.00000015 + usage.output * 0.0000006, 2)

      base <> " Current token usage: (In: #{usage.input}, Out: #{usage.output}, Cost: $#{cost})"
    else
      base
    end
  end

  defp llm_handler(lc_pid, myself) do
    %{
      on_llm_new_delta: fn _model, %MessageDelta{} = data ->
        # we received a piece of data
        send_update(lc_pid, myself, chat_response: data)
      end,
      on_message_processed: fn _chain, %Message{} = _data ->
        nil
      end,
      on_llm_token_usage: fn _model, usage ->
        send_update(lc_pid, myself, usage_update: usage)
      end
    }
  end

  defp format_msg(content) do
    content |> MDEx.to_html!() |> Phoenix.HTML.raw()
  end

  defp system_prompt("ApplicationInformation", :index, workspace_id) do
    workspace = Composer.get_workspace!(workspace_id, [:application_information])

    """
    FACTS:
    1. The current workspace_id is #{workspace.id}
    2. Application information contains: summary, features, and reference materials
    3. Application Information is stored as a text field in the database
    4. The current content is: #{workspace.application_information.content}

    RULES:
    1. All suggestions must align with the described application type
    2. Maintain consistency with existing features
    3. Generated content must be well-structured with clear sections
    4. Reference materials should be preserved

    CAPABILITIES:
    1. Analyze Application Summary
       - Extract key technologies and components
       - Identify core business objectives
       - Highlight main use cases

    2. Feature Management
       - List all current features
       - Suggest additional relevant features
       - Identify potential feature gaps
       - Compare with similar application patterns

    3. Documentation Assistance
       - Suggest documentation improvements
       - Generate structured sections
       - Identify missing critical information
       - Format content for readability

    4. Architecture Analysis
       - Extract architecture components
       - Identify integration points
       - Suggest security considerations
       - Map dependencies

    5. Content Generation
       - Help expand sections
       - Generate missing sections
       - Create structured feature lists
       - Draft technical summaries

    You are an expert application analyst focused on helping users document and understand their applications. Help users maintain clear, comprehensive application documentation while identifying areas for improvement and suggesting relevant additions.
    """
  end

  defp system_prompt("Architecture", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Assumption", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("DataFlow", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Index", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Mitigation", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Show", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Show", :show, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Threat", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Threat", :edit, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("Threat", :new, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt("ThreatModel", :index, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp system_prompt(_, _, workspace_id),
    do: "You are a helpful assistant. When asked the workspace_id is #{workspace_id}"

  defp tag_line("ApplicationInformation", :index),
    do: "Let's work on your application information."

  defp tag_line("Architecture", :index), do: "Arrrrrchitecture, get it?"
  defp tag_line("Assumption", :index), do: "Let's talk about your assumptions."
  defp tag_line("DataFlow", :index), do: "Data is flowing, let's talk about it."
  defp tag_line("Index", :index), do: "Let me help you set up a workspace."
  defp tag_line("Mitigation", :index), do: "This is how we mitigate threats."
  defp tag_line("Show", :index), do: "Let's talk about your workspace."
  defp tag_line("Show", :show), do: "Let's talk about your workspace."
  defp tag_line("Threat", :index), do: "Let's talk about your threats."
  defp tag_line("Threat", :edit), do: "Ok down to brass tacks, let's edit this threat."
  defp tag_line("Threat", :new), do: "Let's create a new threat."
  defp tag_line("ThreatModel", :index), do: "Now that all the hard work is done..."
  defp tag_line(_, _), do: random_tag_line()

  defp random_tag_line() do
    [
      "The pastry chef kneaded a break from his job.",
      "Time flies when you're a watchmaker.",
      "The mathematician counted on his fingers.",
      "That vegetable gardener really knows how to turnip.",
      "The optometrist made a spectacle of himself.",
      "The astronaut needed some space to think.",
      "Piano teachers always note their students' progress.",
      "The electrician conducted himself with shocking professionalism.",
      "The tired calendar just needed a few more dates.",
      "That cheese joke wasn't very mature."
    ]
    |> Enum.random()
  end

  defp role(:assistant), do: "AI Assistant"
  defp role(:user), do: "You"
  defp role(role), do: role
end
