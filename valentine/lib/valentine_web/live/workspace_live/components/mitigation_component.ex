defmodule ValentineWeb.WorkspaceLive.Components.MitigationComponent do
  use ValentineWeb, :live_component
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def render(assigns) do
    ~H"""
    <div style="width:100%">
      <div class="clearfix mb-3">
        <div class="float-left">
          <h3>Mitigation {@mitigation.numeric_id}</h3>
        </div>
        <.live_component
          module={ValentineWeb.WorkspaceLive.Components.LabelSelectComponent}
          id={"mitigations-status-#{@mitigation.id}"}
          parent_id={@myself}
          icon="stack-16"
          default_value="Not set"
          value={@mitigation.status}
          field="status"
          items={[
            {:identified, nil},
            {:in_progress, "State--merged"},
            {:resolved, "State--open"},
            {:will_not_action, "State--closed"}
          ]}
        />
        <div class="float-right">
          <.button
            is_icon_button
            aria-label="Edit"
            phx-click={
              JS.patch(~p"/workspaces/#{@mitigation.workspace_id}/mitigations/#{@mitigation.id}/edit")
            }
            id={"edit-mitigation-#{@mitigation.id}"}
          >
            <.octicon name="pencil-16" />
          </.button>
          <.button
            is_icon_button
            is_danger
            aria-label="Delete"
            phx-click={JS.push("delete", value: %{id: @mitigation.id})}
            data-confirm="Are you sure?"
            id={"delete-mitigation-#{@mitigation.id}"}
          >
            <.octicon name="trash-16" />
          </.button>
        </div>
      </div>
      <.styled_html>
        <p>
          {@mitigation.content}
        </p>
      </.styled_html>
      <details class="mt-4">
        <summary>Comments</summary>
        <.live_component
          module={ValentineWeb.WorkspaceLive.Components.TabNavComponent}
          id={"tabs-component-mitigation-#{@mitigation.id}"}
          tabs={[
            %{label: "Write", id: "tab1"},
            %{label: "Preview", id: "tab2"}
          ]}
        >
          <:tab_content :let={tab}>
            <form phx-value-id={@mitigation.id} phx-submit="update_comments" phx-target={@myself}>
              <%= case tab do %>
                <% "tab1" -> %>
                  <.textarea
                    name="comments"
                    class="mt-2"
                    placeholder="Add a comment..."
                    input_id={"comments-for-#{@mitigation.id}"}
                    is_full_width
                    rows="7"
                    value={@mitigation.comments}
                    caption="Markdown is supported"
                  />
                <% "tab2" -> %>
                  <.live_component
                    module={ValentineWeb.WorkspaceLive.Components.MarkdownComponent}
                    id={"markdown-component-mitigation-#{@mitigation.id}"}
                    text={@mitigation.comments}
                  />
              <% end %>
              <.button is_primary class="mt-2" type="submit">Save</.button>
            </form>
          </:tab_content>
        </.live_component>
      </details>
      <hr />
      <div class="clearfix">
        <div class="float-left col-2 mr-2">
          <.text_input
            id={"#{@mitigation.id}-tag-field"}
            name={"#{@mitigation.id}-tag"}
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
          <%= for tag <- @mitigation.tags || [] do %>
            <.button phx-click="remove_tag" phx-value-tag={tag} phx-target={@myself}>
              <span>{tag}</span>
              <.octicon name="x-16" />
            </.button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{selected_label_dropdown: {_id, field, value}}, socket) do
    {:ok, mitigation} =
      Composer.update_mitigation(
        socket.assigns.mitigation,
        %{}
        |> Map.put(field, value)
      )

    {:ok,
     socket
     |> assign(:mitigation, mitigation)}
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
    current_tags = socket.assigns.mitigation.tags || []

    if tag not in current_tags do
      updated_tags = current_tags ++ [tag]

      Composer.update_mitigation(socket.assigns.mitigation, %{tags: updated_tags})

      {:noreply,
       socket
       |> assign(:tag, "")
       |> assign(:mitigation, %{socket.assigns.mitigation | tags: updated_tags})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("add_tag", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("remove_tag", %{"tag" => tag}, socket) do
    updated_tags = List.delete(socket.assigns.mitigation.tags, tag)
    Composer.update_mitigation(socket.assigns.mitigation, %{tags: updated_tags})
    {:noreply, assign(socket, :mitigation, %{socket.assigns.mitigation | tags: updated_tags})}
  end

  @impl true
  def handle_event("set_tag", %{"value" => value} = _params, socket) do
    {:noreply, assign(socket, :tag, value)}
  end

  @impl true
  def handle_event("update_comments", %{"comments" => comments}, socket) do
    Composer.update_mitigation(socket.assigns.mitigation, %{comments: comments})
    {:noreply, assign(socket, :mitigation, %{socket.assigns.mitigation | comments: comments})}
  end
end
