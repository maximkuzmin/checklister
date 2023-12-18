defmodule Checklister.Repo do
  use Ecto.Repo,
    otp_app: :checklister,
    adapter: Ecto.Adapters.Postgres
end
