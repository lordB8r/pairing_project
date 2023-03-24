defmodule PairingProjectWeb.UserHTML do
  use PairingProjectWeb, :html

  import Phoenix.HTML.Form

  embed_templates "user_html/*"

  @doc """
  Renders a user form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def user_form(assigns)

  def list_ptos(nil), do: []
  def list_ptos([]), do: []
  def list_ptos(ptos), do: ptos
end
