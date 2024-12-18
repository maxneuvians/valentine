defmodule ValentineWeb.Helpers.ChatHelper do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(_name, _params, session, socket) do
    {:cont,
     socket
     |> attach_hook(:chatbot, :handle_event, &maybe_receive_chatbot/3)
     |> assign(
       :chatbot,
       Valentine.Cache.get({socket.id, :chatbot}) || session["chatbot"] || "none"
     )}
  end

  defp maybe_receive_chatbot("update_chatbot", %{"chatbot" => chatbot}, socket) do
    chatbot =
      if chatbot == "none" do
        "block"
      else
        "none"
      end

    Valentine.Cache.put({socket.id, :chatbot}, chatbot, expire: :timer.hours(48))

    {:halt,
     socket
     |> assign(:chatbot, chatbot)
     |> push_event("session", %{chatbot: chatbot})}
  end

  defp maybe_receive_chatbot(_, _, socket), do: {:cont, socket}


  def notify_chat(socket, id, status, msg) do
    send_update(ValentineWeb.WorkspaceLive.Components.ChatComponent,
      id: "chat-component",
      skill_result: %{id: id, status: status, msg: msg}
    )

    socket
  end
end
