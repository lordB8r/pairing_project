defmodule PairingProjectWeb.ProjectHTML do
  use PairingProjectWeb, :html

  import Phoenix.HTML.Form

  alias PairingProject.Accounts

  embed_templates "project_html/*"

  @doc """
  Renders a project form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def project_form(assigns)

  def users_select(f, changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:users, [])
      |> Enum.map(& &1.data.id)

    user_opts =
      for user <- Accounts.list_users(),
          do: [
            key: user.first_name <> " " <> user.last_name,
            value: user.id,
            selected: user.id in existing_ids
          ]

    multiple_select(f, :users, user_opts)
  end

  def selected_users(nil), do: []

  def selected_users(users) do
    Accounts.get_users!(users)
  end

  def sprint_pairings(nil), do: []
  def sprint_pairings(sprints), do: sprints

  def display_pairs(nil), do: "No pairings this sprint"

  def display_pairs(pairings) do
    list = pairings["sprint_pairings"]

    Enum.map(list, fn pair ->
      "{" <> get_pair_names(pair) <> "}"
    end)
  end

  defp get_pair_names([dev1, 0]), do: get_full_name(Accounts.get_user!(dev1))
  defp get_pair_names([0, dev2]), do: get_full_name(Accounts.get_user!(dev2))

  defp get_pair_names([dev1, dev2]) do
    d1 = Accounts.get_user!(dev1)
    d2 = Accounts.get_user!(dev2)
    get_full_name(d1) <> " & " <> get_full_name(d2)
  end

  defp get_full_name(dev) do
    dev.last_name <> ", " <> dev.first_name
  end
end
