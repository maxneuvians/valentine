defmodule ValentineWeb.Helpers.LocaleHelper do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, %{"locale" => locale}, _session, socket) do
    Gettext.put_locale(ValentineWeb.Gettext, locale)

    {:halt,
     socket
     |> assign(:locale, locale)
     |> push_event("session", %{locale: locale})}
  end

  def on_mount(:default, _params, session, socket) do
    locale = Valentine.Cache.get({socket.id, :locale}) || session["locale"] || "en"

    Gettext.put_locale(ValentineWeb.Gettext, locale)

    {:cont,
     socket
     |> attach_hook(:locale, :handle_event, &maybe_receive_locale/3)
     |> assign(:locale, locale)}
  end

  defp maybe_receive_locale("change_locale", %{"locale" => locale}, socket) do
    Valentine.Cache.put({socket.id, :locale}, locale, expire: :timer.hours(48))
    Gettext.put_locale(ValentineWeb.Gettext, locale)

    {:halt,
     socket
     |> assign(:locale, locale)
     |> push_event("session", %{locale: locale})}
  end

  defp maybe_receive_locale(_, _, socket), do: {:cont, socket}
end
