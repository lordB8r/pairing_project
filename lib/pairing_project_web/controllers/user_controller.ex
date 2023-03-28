defmodule PairingProjectWeb.UserController do
  use PairingProjectWeb, :controller

  alias PairingProject.Accounts
  alias PairingProject.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, :new, changeset: changeset)
  end

  def new_pto(conn, params) do
    user = Accounts.get_user!(params["user_id"])

    changeset = Accounts.change_user(user)

    render(conn, :new_pto, user: user, changeset: changeset)
  end

  def create_pto(conn, %{"user" => data}) do
    {:ok, date} = Map.get(data, "date") |> Date.from_iso8601()
    user_id = Map.get(data, "user_id")
    user = Accounts.get_user!(user_id)

    pto = list_ptos(user.pto_requests)

    pto =
      if Enum.member?(pto, date) do
        pto
      else
        [date | pto]
      end

    changeset = %{pto_requests: pto}

    case Accounts.update_user(user, changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "PTO added successfully")
        |> redirect(to: ~p"/users/#{user_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new_pto, changeset: changeset, user: user)
    end
  end

  defp list_ptos(nil), do: []
  defp list_ptos([]), do: []
  defp list_ptos(ptos), do: ptos

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, :edit, user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: ~p"/users")
  end
end
