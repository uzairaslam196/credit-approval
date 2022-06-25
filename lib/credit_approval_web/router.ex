defmodule CreditApprovalWeb.Router do
  use CreditApprovalWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CreditApprovalWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CreditApprovalWeb do
    pipe_through :browser

    live "/", CalculateLive.Index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CreditApprovalWeb do
  #   pipe_through :api
  # end
end
