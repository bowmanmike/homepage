defmodule Homepage.Poller do
  use GenServer

  require Logger

  alias Homepage.Store
  alias Homepage.Clients.{Go, TTC, UP, Leafs}

  @poll_interval 5 * 60 * 1000
  @leafs_poll_interval 1000 * 60 * 60

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :poll_ttc, 0)
    Process.send_after(self(), :poll_up, 0)
    Process.send_after(self(), :poll_go, 0)
    Process.send_after(self(), :poll_leafs, 0)

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

  def handle_info(:poll_up, state) do
    Logger.info("polling UP alerts")
    alerts = UP.fetch()

    Store.update_up_alerts(alerts)

    schedule_poll(:up)
    {:noreply, state}
  end

  def handle_info(:poll_go, state) do
    Logger.info("polling Go Transit alerts")
    alerts = Go.fetch()

    Store.update_go_alerts(alerts)

    schedule_poll(:go)
    {:noreply, state}
  end

  def handle_info(:poll_leafs, state) do
    Logger.info("polling Leafs games")
    games = Leafs.fetch()

    Store.update_leafs(games)

    schedule_poll(:leafs)
    {:noreply, state}
  end

  defp schedule_poll(:ttc) do
    Process.send_after(self(), :poll_ttc, @poll_interval)
  end

  defp schedule_poll(:up) do
    Process.send_after(self(), :poll_up, @poll_interval)
  end

  defp schedule_poll(:go) do
    Process.send_after(self(), :poll_go, @poll_interval)
  end

  defp schedule_poll(:leafs) do
    Process.send_after(self(), :poll_leafs, @leafs_poll_interval)
  end
end
