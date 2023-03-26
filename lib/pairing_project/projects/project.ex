defmodule PairingProject.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :length, :integer
    field :name, :string
    field :sprints, {:array, :integer}
    field :users, {:array, :integer}

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:length, :name, :sprints, :users])
    |> validate_required([:length, :name])
  end
end
