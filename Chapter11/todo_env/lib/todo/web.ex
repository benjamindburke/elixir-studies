defmodule Todo.Web do
  use Plug.Router

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
    query_string = conn.query_string

    cached_entries = Todo.WebCache.get({list_name, query_string})
    if cached_entries != nil do
      # serve response from cache if cache contains an entry for this query
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, cached_entries)
    else
      # when cache does not contain an entry for this query, serve it via server processes
      search_by = Map.fetch!(conn.params, "searchBy")
      query = Map.fetch!(conn.params, "query")
      formatted_query =
        case search_by do
          "id" ->
            {parsedInt, ""} = Integer.parse(query)
            parsedInt
          "title" -> query
          "date" -> Date.from_iso8601!(query)
        end
      entries_json =
        list_name
        |> Todo.Cache.server_process()
        |> Todo.Server.entries(formatted_query)
        |> Enum.map(&"{\"date\": \"#{&1.date}\", \"title\": \"#{&1.title}\"}")
        |> Enum.join(",\n")
      entries_json = "[\n#{entries_json}\n]"

      # store the response for future duplicate queries
      Todo.WebCache.store(list_name, {query_string, entries_json})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, entries_json)
    end

  end

  def child_spec(_) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:todo, :port)],
      plug: __MODULE__
    )
  end
end
