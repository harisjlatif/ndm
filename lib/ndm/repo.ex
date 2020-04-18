defmodule Ndm.Repo do
  use Ecto.Repo,
    otp_app: :ndm,
    adapter: Ecto.Adapters.Postgres
end
