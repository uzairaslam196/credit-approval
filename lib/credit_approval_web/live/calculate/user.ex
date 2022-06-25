defmodule CreditApproval.User do
  use Ecto.Schema
  alias CreditApproval.UserAnswer

  import Ecto.Changeset

  embedded_schema do
    field(:email, :string)
    field(:name, :string)

    embeds_many(:user_answers, UserAnswer)
  end

  def changeset(user, attrs \\ %{}) do
    fields = [:email, :name]

    user
    |> cast(attrs, fields)
    |> cast_embed(:user_answers, with: &UserAnswer.changeset/2)
    |> validate_required(fields)
    |> validate_format(:email, ~r/^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,6}$/, max: 15)
    |> validate_length(:name, max: 15)
  end
end
