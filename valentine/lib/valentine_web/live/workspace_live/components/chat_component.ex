defmodule ValentineWeb.WorkspaceLive.Components.ChatComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  alias Valentine.Composer
  alias Valentine.Prompts.PromptRegistry
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
             type: "json_schema",
             json_schema: PromptRegistry.response_schema(),
             callbacks: [llm_handler(self(), socket.assigns.myself)]
           }),
         callbacks: [llm_handler(self(), socket.assigns.myself)]
       }
       |> LLMChain.new!()
     )
     |> assign(:capabilities, nil)
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
      <div :if={@capabilities && length(@capabilities) > 0} class="capabilities">
        <div :for={capability <- @capabilities} class="capability">
          <.button
            type="button"
            phx-click="execute_capability"
            phx-value-id={capability.id}
            phx-target={@myself}
          >
            <%= capability.description %>
          </.button>
        </div>
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

  def update(%{chat_complete: data}, socket) do
    IO.inspect(data)

    {:ok, socket}
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
        Message.new_system!(
          PromptRegistry.get_system_prompt(active_module, active_action, workspace_id)
        ),
        Message.new_user!(value)
      ])

    {:noreply,
     socket
     |> assign(chain: chain)
     |> run_chain()}
  end

  def handle_event("execute_capability", %{"id" => _capability_id}, socket) do
    # capability = find_capability(socket.assigns.capabilities, capability_id)

    # case execute_capability(capability) do
    #  {:ok, result} ->
    #    {:noreply, socket |> put_flash(:info, "Action completed successfully")}
    #  {:error, reason} ->
    #    {:noreply, socket |> put_flash(:error, "Failed to complete action: #{reason}")}
    # end
    {:noreply, socket}
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
      on_message_processed: fn _chain, %Message{} = data ->
        send_update(lc_pid, myself, chat_complete: data)
      end,
      on_llm_token_usage: fn _model, usage ->
        send_update(lc_pid, myself, usage_update: usage)
      end
    }
  end

  defp format_msg(content) do
    case Jason.decode(content) do
      {:ok, %{"content" => content}} ->
        content |> MDEx.to_html!() |> Phoenix.HTML.raw()

      _ ->
        content
        |> String.replace(~r/^\{"content": "/, "")
        |> MDEx.to_html!()
        |> Phoenix.HTML.raw()
    end
  end

  defp tag_line(module, action) do
    PromptRegistry.get_tag_line(module, action)
  end

  defp role(:assistant), do: "AI Assistant"
  defp role(:user), do: "You"
  defp role(role), do: role
end
