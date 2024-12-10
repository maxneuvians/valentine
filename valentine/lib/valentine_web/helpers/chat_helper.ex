defmodule ValentineWeb.Helpers.ChatHelper do
  import Phoenix.LiveView

  def notify_chat(socket, id, status, msg) do
    send_update(ValentineWeb.WorkspaceLive.Components.ChatComponent,
      id: "chat-component",
      skill_result: %{id: id, status: status, msg: msg}
    )

    socket
  end
end
