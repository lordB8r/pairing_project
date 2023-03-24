defmodule PairingProject.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :pto_requests, {:array, :date}

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:last_name, :first_name, :email, :pto_requests])
    |> validate_required([:last_name, :first_name, :email])
  end
end
