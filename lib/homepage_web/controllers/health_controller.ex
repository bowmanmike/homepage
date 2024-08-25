defmodule HomepageWeb.HealthController do
  use HomepageWeb, :controller

  def health(conn, _params) do
    result = Ecto.Adapters.SQL.query!(Homepage.Repo, "SELECT 1", [])
    IO.inspect(result)

    json(conn, %{healthy: true})
  end
end
