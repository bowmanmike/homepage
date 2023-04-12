defmodule Homepage.Repo do
  use Ecto.Repo,
    otp_app: :homepage,
    adapter: Ecto.Adapters.Postgres
end
