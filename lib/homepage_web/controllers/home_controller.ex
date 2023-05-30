defmodule HomepageWeb.HomeController do
  alias Homepage.Store
  use HomepageWeb, :controller

  def index(conn, _params) do
    data = %{
      ttc: Store.ttc_alerts(),
      up: Store.up_alerts(),
      go: Store.go_alerts(),
      leafs: Store.leafs_games()
    }

    json(conn, data)
  end
end
