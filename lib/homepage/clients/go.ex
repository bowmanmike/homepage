defmodule Homepage.Clients.Go do
  alias Homepage.Store

  @base_url "https://api.gotransit.com/Api/ServiceUpdate/en/all"

  def fetch do
    {:ok, go_data} = Req.get(@base_url)

    parsed_alerts = parse_response(go_data)
    Store.update_go_alerts(parsed_alerts)

    parsed_alerts
  end

  defp parse_response(%Req.Response{status: 200, body: body}) do
    last_updated = Map.get(body, "LastUpdated")

    # require IEx
    # IEx.pry()

    body
    |> Map.take(["Trains"])
    |> Enum.flat_map(fn
      {_k, %{"TotalUpdates" => 0}} ->
        []

      {k, v} ->
        flatten_alerts(k, v)
        |> Enum.flat_map(fn
          %{"Notifications" => %{"Notification" => []}} ->
            []

          %{"Notifications" => %{"Notification" => notifications}} = alert ->
            notifications
            |> Enum.map(fn notif ->
              %{
                routes: alert["CorridorName"],
                title: notif["MessageSubject"],
                last_updated: last_updated
              }
            end)
        end)
    end)
  end

  defp flatten_alerts("Buses", bus_alerts), do: bus_alerts["Bus"]
  defp flatten_alerts("Trains", train_alerts), do: train_alerts["Train"]
  defp flatten_alerts("Stations", station_alerts), do: station_alerts["Station"]
end
