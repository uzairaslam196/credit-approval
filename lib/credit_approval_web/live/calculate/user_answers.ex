defmodule CreditApproval.UserAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:question_id, :integer)
    field(:answer, :string)
    field(:answer_type, Ecto.Enum, values: [:float, :boolean])

    # This structiure provides a scalability in system, admin can add/change questions of different types.
    # Later:
    # add another new table for question types e.g income, expenses and add relation in question table.
    # add another new tables to store calculations related information in it. By this way, admin can choose its own operations to perform on inputs.
    # add validation for total_income > expenses
  end

  def changeset(user, attrs) do
    fields = [:question_id, :answer, :answer_type]

    user
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> validate_input()
  end

  defp validate_input(%{changes: %{answer_type: :float, answer: answer}} = changeset) do
    answer
    |> Float.parse()
    |> case do
      {float, ""} when float > 0 -> changeset
      _ -> add_error(changeset, :answer, "must be greater than 0")
    end
  end

  defp validate_input(%{changes: %{answer_type: :boolean, answer: answer}} = changeset) do
    case answer do
      "true" -> changeset
      "false" -> changeset
      _ -> add_error(changeset, :answer, "must be valid boolean")
    end
  end

  defp validate_input(changeset), do: changeset
end
