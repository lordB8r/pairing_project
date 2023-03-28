# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PairingProject.Repo.insert!(%PairingProject.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Faker.Person
alias Faker.Internet
alias PairingProject.Repo
alias PairingProject.Accounts
alias PairingProject.Accounts.User
alias PairingProject.Projects.Project

Repo.delete_all(User)
Repo.delete_all(Project)

Enum.map(0..20, fn _ ->
  Accounts.create_user(%{
    first_name: Person.first_name(),
    last_name: Person.last_name(),
    email: Internet.email()
  })
end)
