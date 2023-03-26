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
end
