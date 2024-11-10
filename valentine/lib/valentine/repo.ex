defmodule Valentine.Repo do
  use Ecto.Repo,
    otp_app: :valentine,
    adapter: Ecto.Adapters.Postgres
end
