defmodule PairingProject.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias PairingProject.Repo

  alias PairingProject.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_users!([]), do: []

  def get_users!(users) do
    user_ids = users |> Enum.map(& &1)

    from(
      u in User,
      where: u.id in ^user_ids,
      select: u
    )
    |> Repo.all()
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns a user's availability for a sprint
  """
  def user_sprint_availability(nil, _sprint_date_range, _threshold), do: false

  def user_sprint_availability(user_id, sprint_date_range, threshold) do
    breached =
      get_user!(user_id)
      |> Map.get(:pto_requests)
      |> maybe_check_dates
      |> Enum.reduce([], fn x, acc ->
        if x in sprint_date_range do
          [x | acc]
        else
          acc
        end
      end)

    length(breached) <= threshold
  end

  defp maybe_check_dates(nil), do: []
  defp maybe_check_dates(list), do: list
end
