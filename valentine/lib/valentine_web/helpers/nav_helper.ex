defmodule ValentineWeb.Helpers.NavHelper do
  use ValentineWeb, :live_view

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_module, :handle_params, &set_active_module/3)}
  end

  defp set_active_module(params, _url, socket) do
    active_module =
      socket.view
      |> to_string()
      |> String.split(".")
      |> Enum.slice(3..-1//1)
      |> case do
        [name | _] -> name
      end

    {:cont,
     socket
     |> assign(active_module: active_module)
     |> assign(:workspace_id, if(params["workspace_id"], do: params["workspace_id"], else: nil))}
  end
end
