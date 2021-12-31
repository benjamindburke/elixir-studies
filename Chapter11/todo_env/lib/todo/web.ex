defmodule Todo.Web do
  use Plug.Router

  @port 5454

  plug :match
  plug :dispatch

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.add_entry(%{ date: date, title: title })

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  delete "/delete_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    id = Map.fetch!(conn.params, "id")

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.delete_entry(id)

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  patch "/update_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    {id, ""} = Integer.parse(Map.fetch!(conn.params, "id"))
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))
    title = Map.fetch!(conn.params, "title")

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.update_entry(%{id: id, date: date, title: title})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    query = Map.fetch!(conn.params, "query")
    formatted_query =
      case Map.fetch!(conn.params, "searchBy") do
        "id" ->
          {parsedInt, ""} = Integer.parse(query)
          parsedInt
        "title" -> query
        "date" -> Date.from_iso8601!(query)
      end

    formatted_entries =
      list_name
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(formatted_query)
      |> Enum.map(&"{\"date\": \"#{&1.date}\", \"title\": \"#{&1.title}\"}")
      |> Enum.join(",\n")

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, "[\n#{formatted_entries}\n]")
  end

  def child_spec(_) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: @port],
      plug: __MODULE__
    )
  end
end
