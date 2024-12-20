defmodule ValentineWeb.Helpers.ControlHelper do
  import Phoenix.Component
  import Phoenix.LiveView

  @nist_id_regex ~r/^[A-Za-z]{2}-\d+(\.\d+)?$/

  def on_mount(_name, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:control, :handle_event, &maybe_receive_control/3)
     |> assign(:nist_id, nil)}
  end

  def maybe_receive_control("view_control_modal", %{"nist_id" => nist_id}, socket) do
    if nist_id && Regex.match?(@nist_id_regex, nist_id) do
      {:halt,
       socket
       |> assign(:nist_id, nist_id)}
    else
      {:halt,
       socket
       |> assign(:nist_id, nil)}
    end
  end

  def maybe_receive_control(_, _, socket), do: {:cont, socket}
end
