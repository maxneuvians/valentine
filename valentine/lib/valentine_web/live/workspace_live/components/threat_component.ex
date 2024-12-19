defmodule ValentineWeb.WorkspaceLive.Components.ThreatComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def render(assigns) do
    if assigns.threat == nil do
      ""
    else
      ~H"""
      <div style="width:100%">
        <div class="clearfix mb-3">
          <div class="float-left">
            <h3>Threat {@threat.numeric_id}</h3>
          </div>
          <.live_component
            module={ValentineWeb.WorkspaceLive.Components.LabelSelectComponent}
            id={"threat-priority-#{@threat.id}"}
            parent_id={@myself}
            icon="list-ordered-16"
            default_value="Not set"
            value={@threat.priority}
            field="priority"
            items={[
              {:low, "State--open"},
              {:medium, nil},
              {:high, "State--closed"}
            ]}
          />
          <.live_component
            module={ValentineWeb.WorkspaceLive.Components.LabelSelectComponent}
            id={"threat-status-#{@threat.id}"}
            parent_id={@myself}
            icon="stack-16"
            default_value="Not set"
            value={@threat.status}
            field="status"
            items={[
              {:identified, "State--closed"},
              {:resolved, "State--open"},
              {:not_useful, nil}
            ]}
          />
          <div class="float-right">
            <.button
              is_icon_button
              aria-label="Edit"
              navigate={~p"/workspaces/#{@threat.workspace_id}/threats/#{@threat.id}"}
            >
              <.octicon name="pencil-16" />
            </.button>
            <.button
              is_icon_button
              is_danger
              aria-label="Delete"
              phx-click={JS.push("delete", value: %{id: @threat.id})}
              data-confirm="Are you sure?"
            >
              <.octicon name="trash-16" />
            </.button>
          </div>
        </div>
        <.styled_html>
          {Valentine.Composer.Threat.show_statement(@threat)}
        </.styled_html>
        <hr />
        <div class="clearfix mt-4">
          <div class="float-left col-2 mr-2">
            <.text_input
              id={"#{@threat.id}-tag-field"}
              name={"#{@threat.id}-tag"}
              placeholder="Add a tag"
              phx-keyup="set_tag"
              phx-target={@myself}
              value={@tag}
            >
              <:group_button>
                <.button phx-click="add_tag" phx-target={@myself}>Add</.button>
              </:group_button>
            </.text_input>
          </div>

          <div class="float-left">
            <%= for tag <- @threat.tags || [] do %>
              <.button phx-click="remove_tag" phx-value-tag={tag} phx-target={@myself}>
                <span>{tag}</span>
                <.octicon name="x-16" />
              </.button>
            <% end %>
          </div>
          <div class="text-bold f4 float-right" style="color:#cecece">
            {stride(@threat.stride)}
          </div>
        </div>
      </div>
      """
    end
  end

  @impl true
  def update(%{selected_label_dropdown: {_id, field, value}}, socket) do
    {:ok, threat} =
      Composer.update_threat(
        socket.assigns.threat,
        %{}
        |> Map.put(field, value)
      )

    {:ok,
     socket
     |> assign(:threat, threat)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:tag, "")}
  end

  @impl true
  def handle_event("add_tag", _params, %{assigns: %{tag: tag}} = socket)
      when byte_size(tag) > 0 do
    current_tags = socket.assigns.threat.tags || []

    if tag not in current_tags do
      updated_tags = current_tags ++ [tag]

      Composer.update_threat(socket.assigns.threat, %{tags: updated_tags})

      {:noreply,
       socket
       |> assign(:tag, "")
       |> assign(:threat, %{socket.assigns.threat | tags: updated_tags})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("add_tag", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("remove_tag", %{"tag" => tag}, socket) do
    updated_tags = List.delete(socket.assigns.threat.tags, tag)
    Composer.update_threat(socket.assigns.threat, %{tags: updated_tags})
    {:noreply, assign(socket, :threat, %{socket.assigns.threat | tags: updated_tags})}
  end

  @impl true
  def handle_event("set_tag", %{"value" => value} = _params, socket) do
    {:noreply, assign(socket, :tag, value)}
  end

  def stride(stride) when is_list(stride) do
    [
      :spoofing,
      :tampering,
      :repudiation,
      :information_disclosure,
      :denial_of_service,
      :elevation_of_privilege
    ]
    |> Enum.reduce("", fn c, acc ->
      first_char = Atom.to_string(c) |> String.at(0) |> String.upcase()

      acc <>
        if Enum.member?(stride, c),
          do: "<span class=\"Label--accent\">#{first_char}</span>",
          else: first_char
    end)
    |> Phoenix.HTML.raw()
  end

  def stride(_), do: "STRIDE"
end
