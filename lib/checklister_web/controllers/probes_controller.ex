defmodule ChecklisterWeb.ProbesController do
  use ChecklisterWeb, :controller

  def ready(conn, _), do: respond_ok(conn)
  def live(conn, _), do: respond_ok(conn)

  defp respond_ok(conn) do
    conn
    |> Plug.Conn.send_resp(200, "ok")
    |> Plug.Conn.halt()
  end
end
