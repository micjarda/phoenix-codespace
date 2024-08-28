defmodule Ylapi.TodoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ylapi.Todo` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        completed: true,
        name: "some name"
      })
      |> Ylapi.Todo.create_task()

    task
  end
end
