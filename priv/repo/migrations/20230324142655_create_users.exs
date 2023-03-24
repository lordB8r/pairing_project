defmodule PairingProject.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :last_name, :string
      add :first_name, :string
      add :email, :string
      add :pto_requests, {:array, :date}

      timestamps()
    end
  end
end
