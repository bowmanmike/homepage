defmodule Homepage.Poller do
  use GenServer

  require Logger

  alias Homepage.Store
  alias Homepage.Clients.{TTC, UP}

  @poll_interval 5 * 60 * 1000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :poll_ttc, 0)
    Process.send_after(self(), :poll_up, 0)

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

  defp schedule_poll(:ttc) do
    Process.send_after(self(), :poll_ttc, @poll_interval)
  end

  defp schedule_poll(:up) do
    Process.send_after(self(), :poll_up, @poll_interval)
  end

  def refresh_ttc do
    GenServer.cast(__MODULE__, :poll_ttc)
  end

  def refresh_up do
    GenServer.cast(__MODULE__, :poll_up)
  end
end
