defmodule CreditApproval.QuestionsData do

  # Later on build table for questions
  def questions() do
    [
      %{
        index: 1,
        id: 1,
        description: "Do You have a paying job?",
        stage: 1,
        points: 4,
        answer_type: :boolean
      },
      %{
        index: 2,
        id: 2,
        description: "Did you consistently had a paying job for past 12 months?",
        stage: 1,
        points: 2,
        answer_type: :boolean
      },
      %{
        index: 3,
        id: 3,
        description: "Do you own a home?",
        stage: 1,
        points: 2,
        answer_type: :boolean
      },
      %{
        index: 4,
        id: 4,
        description: "Do you own a car?",
        stage: 1,
        points: 1,
        answer_type: :boolean
      },
      %{
        index: 5,
        id: 5,
        description: "Do you have any additional source of income?",
        stage: 1,
        points: 2,
        answer_type: :boolean
      },
      %{
        index: 6,
        id: 6,
        description: "What is your total monthly income from all income source?",
        stage: 2,
        points: nil,
        answer_type: :float
      },
      %{
        index: 7,
        id: 7,
        description: "What are their total monthly expenses?",
        stage: 2,
        points: nil,
        answer_type: :float
      }
    ]
  end

   # Later on build table for currencies
  def currencies() do
    [
      %{country: "US", short: "$", active: true},
      %{country: "PK", short: "PKR", active: false}
    ]
  end

  def get_active_currency(), do: Enum.find(currencies(), & &1.active == true)
end
