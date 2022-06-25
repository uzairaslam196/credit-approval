defmodule CreditApprovalWeb.PageController do
  use CreditApprovalWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
