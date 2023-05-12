defmodule Homepage.Clients.Leafs do
  def fetch do
    url()
    |> Req.get!()
    |> handle_response()
  end

  defp handle_response(%Req.Response{status: 200, body: body}) do
    body
    |> Map.get("dates")
    |> Enum.flat_map(fn date ->
      date
      |> Map.get("games")
      |> Enum.take(5)
      |> Enum.map(fn game ->
        {:ok, start_time} =
          game
          |> Map.get("gameDate")
          |> DateTime.from_iso8601()
          |> then(fn {:ok, date, _} -> DateTime.shift_zone(date, "America/Toronto") end)

        %{
          start_time: start_time,
          location: get_in(game, ["venue", "name"]),
          if_necessary:
            game |> Map.get("status") |> Map.get("detailedState") |> String.match?(~r/TBD/),
          opponent:
            Map.get(game, "teams")
            |> Enum.map(fn {_, team} -> Map.get(team, "team") end)
            |> Enum.find(&(Map.get(&1, "name") != "Toronto Maple Leafs"))
            |> Map.get("name")
        }
      end)
    end)
  end

  defp url do
    %URI{
      scheme: "https",
      port: 443,
      host: "statsapi.web.nhl.com",
      path: "/api/v1/schedule",
      query:
        URI.encode_query(%{
          # leafs are team_id 10
          teamId: 10,
          startDate: DateTime.utc_now() |> DateTime.to_date(),
          endDate: DateTime.utc_now() |> DateTime.add(365, :day) |> DateTime.to_date()
        })
    }
  end
end
