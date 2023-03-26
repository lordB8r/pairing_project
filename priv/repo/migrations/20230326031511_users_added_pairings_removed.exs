defmodule PairingProject.Repo.Migrations.UsersAddedPairingsRemoved do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :users, {:array, :integer}
      add :sprints, {:array, :integer}
    end
  end
end
