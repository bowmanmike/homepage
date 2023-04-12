defmodule Homepage.Poller do
  use GenServer

  require Logger

  alias Homepage.Store
  alias Homepage.Clients.TTC

  @poll_interval 5 * 60 * 1000
  # @poll_interval 3000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :poll_ttc, 0)

    {:ok, nil}
  end

  @impl true
  def handle_info(:poll_ttc, state) do
    Logger.info("polling TTC alerts")
    alerts = TTC.fetch()

    Store.update_ttc_alerts(alerts)

    schedule_poll(:ttc)
    {:noreply, state}
  end

  defp schedule_poll(:ttc) do
    Process.send_after(self(), :poll_ttc, @poll_interval)
  end
end
