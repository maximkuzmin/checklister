defmodule ChecklisterWeb.ErrorJSONTest do
  use ChecklisterWeb.ConnCase, async: true

  test "renders 404" do
    assert ChecklisterWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ChecklisterWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
