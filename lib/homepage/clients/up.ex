defmodule Homepage.Clients.UP do
  alias Homepage.Store

  @base_url "https://www.upexpress.com/SchedulesStations/ServiceStatus"

  def fetch do
    {:ok, up_data} = Req.get(@base_url)

    parsed_alerts = parse_response(up_data)
    update_store(parsed_alerts)

    parsed_alerts
  end

  defp parse_response(%Req.Response{status: 200, body: body}) do
    body
    |> Floki.parse_document!()
    |> Floki.find("#serviceStatusLeftMargin")
    |> Floki.find("h3 ~ div")
    |> Floki.text()
    |> String.trim()
    |> String.split("\r\n")
    |> Enum.map(&String.trim/1)
    |> Enum.chunk_every(2)
  end

  defp update_store(data) do
    Store.update_up_alerts(data)
  end

  defp html_selectors do
    [
      # generic
      '',
      '#paddingstatus div:contains("Union Station")',
      '#paddingstatus div:contains("Bloor Station")',
      '#paddingstatus div:contains("Weston Station")',
      '#paddingstatus div:contains("Pearson Station")'
    ]
  end
end
