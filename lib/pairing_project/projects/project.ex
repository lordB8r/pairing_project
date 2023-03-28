defmodule PairingProject.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :length, :integer
    field :name, :string
    field :sprints, {:array, :map}
    field :users, {:array, :integer}
    field :startdate, :date
    field :vacation_threshold, :integer

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:length, :name, :sprints, :users, :startdate, :vacation_threshold])
    |> validate_required([:length, :name, :startdate, :vacation_threshold])
  end
end
