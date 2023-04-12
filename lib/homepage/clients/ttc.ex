defmodule Homepage.Clients.TTC do
  alias Homepage.Store

  @base_url "https://alerts.ttc.ca/api/alerts/live-alerts"
  @type alert :: %{
          last_updated: :string,
          route: :string,
          route_type: :string,
          title: :string
        }

  @spec fetch :: [alert]
  def fetch do
    {:ok, ttc_data} = Req.get(@base_url)

    parsed_alerts = parse_response(ttc_data)
    update_store(parsed_alerts)

    parsed_alerts
  end

  defp parse_response(%Req.Response{status: 200, body: body}) do
    body
    |> Map.get("routes")
    |> Enum.map(fn alert ->
      %{
        last_updated: Map.get(alert, "lastUpdated"),
        route: Map.get(alert, "route"),
        route_type: Map.get(alert, "routeType"),
        title: Map.get(alert, "title")
      }
    end)
  end

  defp update_store(alerts) do
    Store.update_ttc_alerts(alerts)

    alerts
  end
end
