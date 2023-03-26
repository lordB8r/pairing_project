defmodule PairingProject.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PairingProject.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        length: 42,
        name: "some name",
        pairings: [1, 2]
      })
      |> PairingProject.Projects.create_project()

    project
  end
end
