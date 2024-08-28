defmodule YlapiWeb.TaskControllerTest do
  use YlapiWeb.ConnCase

  import Ylapi.TodoFixtures

  @create_attrs %{name: "some name", completed: true}
  @update_attrs %{name: "some updated name", completed: false}
  @invalid_attrs %{name: nil, completed: nil}

  describe "index" do
    test "lists all tasks", %{conn: conn} do
      conn = get(conn, ~p"/tasks")
      assert html_response(conn, 200) =~ "Listing Tasks"
    end
  end

  describe "new task" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/tasks/new")
      assert html_response(conn, 200) =~ "New Task"
    end
  end

  describe "create task" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/tasks", task: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/tasks/#{id}"

      conn = get(conn, ~p"/tasks/#{id}")
      assert html_response(conn, 200) =~ "Task #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/tasks", task: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Task"
    end
  end

  describe "edit task" do
    setup [:create_task]

    test "renders form for editing chosen task", %{conn: conn, task: task} do
      conn = get(conn, ~p"/tasks/#{task}/edit")
      assert html_response(conn, 200) =~ "Edit Task"
    end
  end

  describe "update task" do
    setup [:create_task]

    test "redirects when data is valid", %{conn: conn, task: task} do
      conn = put(conn, ~p"/tasks/#{task}", task: @update_attrs)
      assert redirected_to(conn) == ~p"/tasks/#{task}"

      conn = get(conn, ~p"/tasks/#{task}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, ~p"/tasks/#{task}", task: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Task"
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, ~p"/tasks/#{task}")
      assert redirected_to(conn) == ~p"/tasks"

      assert_error_sent 404, fn ->
        get(conn, ~p"/tasks/#{task}")
      end
    end
  end

  defp create_task(_) do
    task = task_fixture()
    %{task: task}
  end
end
