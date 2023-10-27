defmodule HomepageWeb.HomeLive do
  use HomepageWeb, :live_view

  import HomepageWeb.Components.CollapsibleSection

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
    timestamp
    |> maybe_append_z()
    |> DateTime.from_iso8601()
    |> then(fn {:ok, ts, _offset} -> ts end)
    |> Calendar.strftime("%H:%m %P, %a %d %b %Y")
  end

  defp format_leafs_start_time(%{if_necessary: false, start_time: time}) do
    Calendar.strftime(time, "%A, %B %d at %-I:%M %p")
  end

  defp format_leafs_start_time(%{start_time: time}) do
    Calendar.strftime(time, "%A, %B %d")
  end

  @game_types %{
    "PR" => "Preseason",
    "R" => "Regular Season",
    "P" => "Playoffs"
  }

  defp format_leafs_game_type(%{game_type: game_type}) do
    Map.get(@game_types, game_type, "Unknown")
  end

  defp up_alerts_present?(alerts) do
    Enum.any?(alerts, fn %{message: message} -> message != "" end)
  end

  defp up_alerts_count(alerts) do
    alerts
    |> Enum.filter(fn %{message: message} -> message != "" end)
    |> Enum.count()
  end

  defp maybe_append_z(str) do
    case String.ends_with?(str, "Z") do
      true -> str
      false -> str <> "Z"
    end
  end
end
