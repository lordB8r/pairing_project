defmodule PairingProject.Repo.Migrations.AddProjectStartdate do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :vacation_threshold, :integer
      add :startdate, :date
    end
  end
end
