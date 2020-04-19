defmodule NdmWeb.LayoutView do
  use NdmWeb, :view

  def active_class(conn, path) do
    current_path = Path.join(["/" | conn.path_info])

    if path == current_path do
      "is-active"
    else
      nil
    end
  end

  def active_link(text, conn, opts) do
    class = [opts[:class], active_class(conn, opts[:to])] |> Enum.filter(& &1) |> Enum.join(" ")
    opts = opts |> Keyword.put(:class, class) |> Keyword.put(:to, opts[:to])
    link(text, opts)
  end
end
