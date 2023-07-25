defmodule HomepageWeb.HomeLive do
  use HomepageWeb, :live_view

  alias Homepage.Store

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign_ttc_alerts()
    |> assign_up_alerts()
    |> assign_go_alerts()
    |> assign_leafs_games()
    |> reply_ok()
  end

  defp assign_ttc_alerts(socket) do
    assign(socket, :ttc_alerts, Store.ttc_alerts())
  end

  defp assign_up_alerts(socket) do
    assign(socket, :up_alerts, Store.up_alerts())
  end

  defp assign_go_alerts(socket) do
    assign(socket, :go_alerts, Store.go_alerts())
  end

  defp assign_leafs_games(socket) do
    games = Store.leafs_games() |> Enum.slice(0..9)

    assign(socket, :leafs_games, games)
  end

  def format_last_updated(timestamp) do
    {:ok, date_time, _offset} = DateTime.from_iso8601(timestamp <> "Z")

    Calendar.strftime(date_time, "%H:%m %P, %a %d %b %Y")
  end

  defp format_leafs_start_time(%{if_necessary: false, start_time: time}) do
    Calendar.strftime(time, "%A, %B %d at %-I:%M %p")
  end

  defp format_leafs_start_time(%{start_time: time}) do
    Calendar.strftime(time, "%A, %B %d")
  end
end
