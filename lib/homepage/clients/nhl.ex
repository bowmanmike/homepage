defmodule Homepage.Clients.NHL do
  @game_types %{
    1 => :pre_season,
    2 => :regular_season
  }

  @team_abbreviations %{
    "ANA" => "Anaheim Ducks",
    "ARI" => "Arizona Coyotes",
    "BOS" => "Boston Bruins",
    "BUF" => "Buffalo Sabres",
    "CAR" => "Carolina Hurricanes",
    "CBJ" => "Columbus Blue Jackets",
    "CGY" => "Calgary Flames",
    "CHI" => "Chicago Blackhawks",
    "COL" => "Colorado Avalanche",
    "DAL" => "Dallas Stars",
    "DET" => "Detroit Red Wings",
    "EDM" => "Edmonton Oilers",
    "FLA" => "Florida Panthers",
    "LAK" => "Los Angeles Kings",
    "MIN" => "Minnesota Wild",
    "MTL" => "Montreal Canadiens",
    "NJD" => "New Jersey Devils",
    "NSH" => "Nashville Predators",
    "NYI" => "New York Islanders",
    "NYR" => "New York Rangers",
    "OTT" => "Ottawa Senators",
    "PHI" => "Philadelphia Flyers",
    "PIT" => "Pittsburgh Penguins",
    "SEA" => "Seattle Kraken",
    "SEN" => "Ottawa Senators",
    "SJS" => "San Jose Sharks",
    "STL" => "St. Louis Blues",
    "TBL" => "Tampa Bay Lightning",
    "TOR" => "Toronto Maple Leafs",
    "VAN" => "Vancouver Canucks",
    "VGK" => "Vegas Golden Knights",
    "WPG" => "Winnipeg Jets",
    "WSH" => "Washington Capitals"
  }

  def fetch() do
    url()
    |> Req.get!()
    |> handle_response()
  end

  defp handle_response(%Req.Response{status: 200, body: body}) do
    # require IEx; IEx.pry
    now = DateTime.now!("UTC")

    body
    |> Map.get("games")
    |> Enum.filter(fn %{"startTimeUTC" => game_date} ->
      {:ok, date, _} = DateTime.from_iso8601(game_date)

      DateTime.after?(date, now)
    end)
    |> Enum.take(10)
    |> Enum.map(fn game ->
      {:ok, start_time} =
        game
        |> Map.get("startTimeUTC")
        |> DateTime.from_iso8601()
        |> then(fn {:ok, date, _} -> DateTime.shift_zone(date, "America/Toronto") end)

      %{
        start_time: start_time,
        location: Map.get(game, "venue") |> Map.get("default"),
        # TODO: fix this when we get playofs
        if_necessary: false,
        opponent:
          game
          |> Map.take(["homeTeam", "awayTeam"])
          |> Enum.map(fn {_key, value} -> value["abbrev"] end)
          |> Enum.find(fn team -> team != "TOR" end)
          |> then(fn team ->Map.get(@team_abbreviations, team) end),
        game_type: Map.get(@game_types, game["gameType"])
      }
    end)
  end

  defp url() do
    %URI{
      scheme: "https",
      port: 443,
      host: "api-web.nhle.com",
      path: "/v1/club-schedule-season/tor/20232024"
    }
  end
end
