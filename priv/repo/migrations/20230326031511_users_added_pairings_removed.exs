defmodule PairingProject.Repo.Migrations.UsersAddedPairingsRemoved do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :users, {:array, :integer}, default: []
      add :sprints, {:array, :map}, default: []
    end
  end
end
