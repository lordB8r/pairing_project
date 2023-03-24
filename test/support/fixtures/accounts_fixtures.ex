defmodule PairingProject.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PairingProject.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "some first_name",
        last_name: "some last_name",
        pto_requests: []
      })
      |> PairingProject.Accounts.create_user()

    user
  end
end
