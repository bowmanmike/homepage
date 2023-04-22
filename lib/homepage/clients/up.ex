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
    # require IEx
    # IEx.pry()

    body
    |> Floki.parse_document!()
    |> then(fn html ->
      Enum.map(html_selectors(), fn {station, selector} ->
        html
        |> Floki.find(selector)
        |> then(fn content ->
          # require IEx
          # IEx.pry()

          %{
            station: station,
            date: text_from_selector(content, ".StatusDateSemibold"),
            timestamp: text_from_selector(content, ".Timestap1"),
            message: text_from_selector(content, ".MargnBottom10Services:nth-of-type(2)")
          }
        end)
      end)
    end)
  end

  defp update_store(data) do
    Store.update_up_alerts(data)
  end

  defp html_selectors do
    %{
      generic: "",
      union: "#paddingstatus > div:fl-icontains(\"Union Station\") + div",
      bloor: "#paddingstatus > div:fl-icontains(\"Bloor Station\") + div",
      weston: "#paddingstatus > div:fl-icontains(\"Weston Station\") + div",
      pearson: "#paddingstatus > div:fl-icontains(\"Pearson Station\") + div"
    }
  end

  defp text_from_selector(parsed_html, selector) do
    parsed_html |> Floki.find(selector) |> Floki.text() |> String.trim()
  end
end
