defmodule CreditApproval.ApprovalClient do
  def credit_score_request(points) do
    build()
    |> Tesla.get("/creditScore/#{points}")
    |> case do
      {:ok, %Tesla.Env{status: 200, body: body}} -> {:ok, body}
      _ -> {:error, :request_error}
    end
  end

  def build() do
    headers = [{"Content-Type", "application/json"}]

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url()},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers}
    ]

    Tesla.client(middleware)
  end

  defp base_url(), do: "https://lxzau4xjot.api.quickmocker.com"
end
