# lib/your_app_web/live/components/context_help_component.ex
defmodule ValentineWeb.WorkspaceLive.Threat.Components.ContextHelpComponent do
  use ValentineWeb, :live_component

  @impl true
  def update(assigns, socket) do
    current_value =
      if assigns.active_field do
        get_field_value(assigns.form, assigns.active_field)
      else
        ""
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_value, current_value)}
  end

  defp get_field_value(form, field) do
    case form.params[Atom.to_string(field)] || Ecto.Changeset.get_field(form.source, field) do
      nil -> ""
      value -> value
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-6">
      <div class="col-span-2">
        <div class="border rounded-lg p-6 bg-white">
          <h2 class="text-xl font-semibold mb-2"><%= @title %></h2>
          <p class="text-gray-600 mb-4"><%= @description %></p>

          <div class="space-y-4">
            <.input
              type="textarea"
              field={@form[@active_field]}
              placeholder={@placeholder}
              rows="4"
              class="w-full"
              name={"threat[#{@active_field}]"}
              id={"#{@id}-#{@active_field}"}
              phx-change="update_field"
              phx-target={@myself}
            />
          </div>
        </div>
      </div>

      <div class="col-span-1">
        <div class="border rounded-lg p-6 bg-white">
          <h3 class="font-medium mb-4">Inputs for mitigation</h3>
          <ul class="space-y-2">
            <li :for={{key, input} <- @mitigation_inputs} class="flex items-center gap-2">
              <%= if field_completed?(@form.source, key) do %>
                <.icon name="hero-check-circle-solid" class="text-green-500" />
              <% else %>
                <.icon name="hero-minus-circle" />
              <% end %>
              <span><%= input %></span>
            </li>
          </ul>

          <div class="border-t my-4"></div>

          <h3 class="font-medium mb-4">Inputs for prioritization</h3>
          <ul class="space-y-2">
            <li :for={{key, input} <- @prioritization_inputs} class="flex items-center gap-2">
              <%= if field_completed?(@form.source, key) do %>
                <.icon name="hero-check-circle-solid" class="text-green-500" />
              <% else %>
                <.icon name="hero-minus-circle" />
              <% end %>
              <span><%= input %></span>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("update_field", %{"threat" => params}, socket) do
    value = params[Atom.to_string(socket.assigns.active_field)]
    send(self(), {:update_field, value})
    {:noreply, socket}
  end

  defp field_completed?(changeset, field) do
    value =
      Ecto.Changeset.get_change(changeset, field) ||
        Ecto.Changeset.get_field(changeset, field)

    value && String.trim(to_string(value)) != ""
  end
end
