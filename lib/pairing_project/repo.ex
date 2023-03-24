defmodule PairingProject.Repo do
  use Ecto.Repo,
    otp_app: :pairing_project,
    adapter: Ecto.Adapters.Postgres
end
