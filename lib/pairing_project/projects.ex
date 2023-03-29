defmodule PairingProject.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias PairingProject.Repo

  alias PairingProject.Accounts
  alias PairingProject.Projects.Project

  def list_projects do
    Repo.all(Project)
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  def change_project(%Project{} = project, attrs \\ %{}) do
    users = Accounts.list_users()

    Map.put(project, :available_users, users)
    |> Project.changeset(attrs)
  end

  @doc """
  Projects.generate_sprint_date_ranges(4, ~D[2023-03-27])
  [
    %{daterange: Date.range(~D[2023-03-27], ~D[2023-03-31]), id: 1, pairings: []},
    %{daterange: Date.range(~D[2023-04-03], ~D[2023-04-07]), id: 2, pairings: []},
    %{daterange: Date.range(~D[2023-04-10], ~D[2023-04-14]), id: 3, pairings: []},
    %{daterange: Date.range(~D[2023-04-17], ~D[2023-04-21]), id: 4, pairings: []}
  ]
  """
  def generate_sprint_date_ranges(n_sprints, start_date) do
    Enum.map(0..(n_sprints - 1), fn id ->
      startdate = Date.add(start_date, id * 7)
      enddate = Date.add(start_date, id * 7 + 4)

      %{
        id: id + 1,
        daterange: Date.range(startdate, enddate),
        startdate: startdate,
        pairings: []
      }
    end)
  end

  @doc """
  Generates the best pairing rotation for the project based on Project properties
  developers: users
  length: length of project
  start_date: date project starts (assumed to be a monday, no validation currently)
  threshold: how many vacation days before a developer is not eligible to participate in a sprint

  $> generate_pairing_rotation(pairing_rotation)
  returns:
  $> [
      %{
        daterange: Date.range(~D[2023-03-27], ~D[2023-03-31]),
        id: 1,
        pairings: %{sp: [[2, 3], [0, 1]], ud: [2, 3, 0, 1]}
      },
      %{
        daterange: Date.range(~D[2023-04-03], ~D[2023-04-07]),
        id: 2,
        pairings: %{sp: [[0, 1], [2, 3]], ud: [0, 1, 2, 3]}
      },
      %{
        daterange: Date.range(~D[2023-04-10], ~D[2023-04-14]),
        id: 3,
        pairings: %{sp: [[0, 1], [2, 3]], ud: [0, 1, 2, 3]}
      }
    ]
  """
  def generate_pairing_rotation(%Project{} = project) do
    developers = project.users
    n_sprints = project.length
    start_date = project.startdate
    sprints = generate_sprint_date_ranges(n_sprints, start_date)
    threshold = project.vacation_threshold

    # Enumerate all the sprints, and build the custom list for each week
    final_pairings =
      Enum.reduce(1..n_sprints, [], fn id, sprints_acc ->
        sprint = Enum.find(sprints, fn map -> map.id == id end)

        # make sure the developer is available this sprint
        # for this sprint, create list of eligible engineers
        %{devs: developers_available_this_sprint, vacay: vacay_devs} =
          developers_available_for_this_sprint(developers, sprint.daterange, threshold)

        vacay_devs |> IO.inspect(label: "projects.ex:107")

        max_pairings_this_sprint = (length(developers_available_this_sprint) / 2) |> ceil()

        # generate potential list of pairings based on eligible engineers
        potential_pairings_for_this_sprint =
          generate_all_pairings(developers_available_this_sprint)

        # Generate a limited pairing set based on max_pairings_this_sprint
        created_pairing =
          build_sprint_pairings(
            potential_pairings_for_this_sprint |> Enum.shuffle(),
            max_pairings_this_sprint
          )
          |> Map.put(:devs_on_vacay, vacay_devs)

        [%{sprint | pairings: created_pairing} | sprints_acc]
      end)

    changeset_pairings =
      final_pairings
      |> Enum.map(fn x -> generate_changeset_mappings(x) end)
      |> Enum.sort()

    project
    |> Project.changeset(%{sprints: changeset_pairings})
    |> Repo.update()

    final_pairings
  end

  defp generate_changeset_mappings(map) do
    %{id: map.id, pairings: map.pairings, startdate: map.startdate}
  end

  ###
  ### Generates all possible pairings for the given list of developers, and starts list of
  ### sprints the pairing was used in.
  ###
  ### [
  ###  ..
  ###  %{pair: {7, 6}, sprint_used: []},
  ###  %{pair: {7, nil}, sprint_used: []},
  ###  %{pair: {1, 2}, sprint_used: []},
  ###  ..
  ### ]

  defp generate_all_pairings(developers) do
    count = length(developers)

    Enum.flat_map(0..(count - 1), fn i ->
      Enum.map(i..count, fn j ->
        if i != j do
          [dev_value(Enum.at(developers, i)), dev_value(Enum.at(developers, j))]
          |> Enum.sort()
        end
      end)
    end)
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == [0, 0]))
  end

  defp dev_value(nil), do: 0
  defp dev_value(value), do: value

  defp used_pairings_check(nil), do: 0
  defp used_pairings_check([]), do: 0
  defp used_pairings_check(sprint), do: length(sprint.pairings)

  defp build_sprint_pairings(pairings, max_pairs) do
    pairings
    |> Enum.reduce_while(
      %{sprint_pairings: [], used_devs: []},
      fn pair, acc = %{sprint_pairings: sprint_pairings, used_devs: used_devs} ->
        if length(sprint_pairings) <= max_pairs do
          {:cont,
           if check_dev_against_list!(used_devs, pair) do
             # list of lists
             %{acc | sprint_pairings: [pair | sprint_pairings], used_devs: pair ++ used_devs}
           else
             acc
           end}
        else
          {:halt, {sprint_pairings, used_devs}}
        end
      end
    )
  end

  defp check_dev_against_list!(_list, nil), do: false
  defp check_dev_against_list!(nil, _dev), do: false

  defp check_dev_against_list!(used_dev, [a | [b | _]]) do
    case Enum.find(used_dev, fn x -> x == a or x == b end) do
      nil -> true
      _ -> false
    end
  end

  defp developers_available_for_this_sprint(developers, daterange, threshold) do
    developers
    |> Enum.reduce(%{devs: [], vacay: []}, fn dev, acc = %{devs: devs, vacay: vacay} ->
      if Accounts.user_sprint_availability(dev, daterange, threshold) do
        %{acc | devs: [dev | devs]}
      else
        %{acc | vacay: [dev | vacay]}
      end
    end)
  end
end
