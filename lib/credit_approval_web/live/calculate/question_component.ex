defmodule CreditApprovalWeb.Live.QuestionComponent do
  use CreditApprovalWeb, :live_component

  alias CreditApproval.ApprovalClient
  alias CreditApproval.QuestionsData
  alias CreditApproval.User
  alias Ecto.Changeset

  @first_stage 0
  @currency Application.get_env(:credit_approval, :currency)

  @impl true
  def update(_assigns, socket) do
    changeset = User.changeset(%User{})
    questions = QuestionsData.questions() |> Enum.sort_by(& &1.index)

    socket
    |> assign(:stage, @first_stage)
    |> assign(:changeset, changeset)
    |> assign(:questions, questions)
    |> assign(:questions_map, Map.new(questions, &{&1.id, &1}))
    |> then(&assign(&1, :question, List.first(&1.assigns.questions)))
    |> assign(:user_answers, [])
    |> ok()
  end

  @impl true

  def handle_event("validate", %{"user" => user}, socket) do
    socket
    |> validate_changeset(%User{}, user)
    |> may_be_validate_expense()
    |> noreply()
  end

  def handle_event("save", %{"user" => %{"user_answers" => _} = user}, socket) do
    socket
    |> validate_changeset(%User{}, user)
    |> may_be_validate_expense()
    |> process_calculation()
    |> noreply()
  end

  def handle_event("save", %{"user" => user}, socket) do
    socket
    |> validate_changeset(%User{}, user)
    |> then(&if &1.assigns.changeset.valid?, do: assign(&1, :stage, 1), else: &1)
    |> noreply()
  end

  def handle_event("back", _, %{assigns: assigns} = socket) do
    question =
      assigns.questions
      |> Enum.reverse()
      |> Enum.find(&(&1.index < assigns.question.index))

    socket
    |> assign(:question, question)
    |> assign(:stage, 1)
    |> then(& assign(&1, :user_answers,
      Enum.reject(assigns.user_answers, fn answer ->
        answer
      end)
    ))
    |> noreply()
  end

  def handle_event("boolean", %{"ans" => ans}, socket) do
    %{assigns: %{changeset: changeset, question: question} = assigns} = socket
    answer = %{question_id: question.id, answer: ans, answer_type: question.answer_type}

    user_answers = %{user_answers: [answer | assigns.user_answers]}
    question = Enum.find(assigns.questions, &(&1.index > question.index))

    socket
    |> assign(:question, question)
    |> validate_changeset(changeset, user_answers)
    |> assign(:user_answers, [answer | assigns.user_answers])
    |> then(&assign(&1, stage: question.stage))
    |> may_be_next_stage(question)
    |> noreply()
  end

  defp validate_changeset(socket, changeset, user) do
    changeset =
      changeset
      |> User.changeset(user)
      |> Map.put(:action, :validate)

    assign(socket, :changeset, changeset)
  end

  def may_be_validate_expense(%{assigns: %{stage: 2}} = socket)
    when socket.assigns.changeset.valid? do
    changeset = socket.assigns.changeset

    [income, expense] =
      changeset.changes.user_answers
      |> Enum.sort_by(& &1.changes.question_id)
      |> Enum.filter(& &1.changes.question_id in [6, 7])
      |> Enum.map(& &1.changes.answer)

    true? = elem(Float.parse(income), 0) > elem(Float.parse(expense), 0)

    if true? do
      clear_flash(socket)
    else
      socket
      |> assign(:changeset, Map.put(changeset, :valid?, false))
      |> put_flash(:error, "Total Expense must be less than income")
    end
  end

  def may_be_validate_expense(socket), do: socket

  defp may_be_next_stage(socket, %{answer_type: :boolean}), do: socket
  defp may_be_next_stage(%{assigns: assigns} = socket, %{answer_type: :float} = _question) do
    if calculate_points(assigns) > 6 do
      user_answers =
        assigns.questions
        |> Enum.filter(&(&1.answer_type == :float))
        |> Enum.map(&%{question_id: &1.id, answer_type: :float})
        |> Enum.concat(assigns.user_answers)

      changeset = User.changeset(assigns.changeset, %{user_answers: user_answers})
      assign(socket, :changeset, changeset)
    else
      send(self(), {:not_approved, assigns.changeset.changes.name})
      socket
    end
  end

  @impl true
  def render(assigns) do
    class = "cursor-pointer #{assigns.question.index < 2 && 'invisible'}"

    ~H"""
    <div class="main h-300">
      <div class={"danger q-heading #{!@flash["error"] && 'invisible'}"}> Oops, <%= @flash["error"] %> </div>
      <span phx-click="back" class={class} phx-target={@myself}><a>Back</a></span>

      <div class="q-heading">
        <h3>Questioning Process</h3>
        <p><%= heading(@stage) %></p>
      </div>

      <%= if @stage == 0 do %>
          <.form_for {assigns} f={@changeset} fields={[:name, :email]}/>
      <% end %>

      <%= if @stage == 1 do %>
          <p class="f-w-4 q-heading"><%= @question.description %></p>
          <div class="btns">
            <button phx-click="boolean" phx-value-ans="true" phx-target={@myself}>Yes</button>
            <button phx-click="boolean" phx-value-ans="false" phx-target={@myself}>No</button>
          </div>
      <% end %>

      <%= if @stage == 2 do %>
          <.form_for {assigns} f={@changeset} fields={[:answer]}/>
      <% end %>
    </div>
    """
  end

  defp form_for(%{f: form_for} = assigns) do
    ans_hide_inputs = [:question_id, :answer_type, :answer]
    user_hide_inputs = [:email, :name]

    ~H"""
      <.form let={f} for={form_for} phx-target={@myself} phx-change="validate" phx-submit="save">
        <.hidden_inputs {assigns} f={f} fields={user_hide_inputs} />
        <%= if @stage == 0 do %>
          <.fields {assigns} f={f} />
        <% end %>

        <%= inputs_for f, :user_answers, fn a -> %>
          <.hidden_inputs {assigns} f={a} fields={ans_hide_inputs} />
          <%= if float_answer?(@questions_map, a) do %>
            <.fields {assigns} f={a} />
          <% end %>
        <% end %>

        <%= if @stage != 1 do %>
          <button type="submit">Submit</button>
        <% end %>
      </.form>
    """
  end

  defp fields(%{f: f} = assigns) do
    fields = assigns[:fields] || []

    ~H"""
      <%= for key <- fields do %>
        <div style="width: 100%">
          <.field_label {assigns} key={key} />
          <.field_input {assigns} key={key} />
          <%= error_tag f, key %>
        </div>
      <% end %>
    """
  end

  defp field_input(%{stage: 2} = assigns), do: ~H[<%= number_input(@f, @key)%>]
  defp field_input(%{stage: _} = assigns), do: ~H[<%= text_input(@f, @key) %>]

  defp field_label(%{stage: 2, f: f, questions_map: questions_map} = assigns) do
    question = Map.get(questions_map, f.source.changes.question_id)
    {currency, _sign} = @currency

    ~H"""
    <div class="label">
      <%= label(@f, @key, question.description) %>
      <span class="label-s-1">(<%= currency %>)</span>
    </div>
    """
  end

  defp field_label(%{stage: _} = assigns), do: ~H[<%= label(@f, @key) %>]

  defp hidden_inputs(%{f: f} = assigns) do
    ~H[<%= for key <- @fields do %> <%= hidden_input f, key %> <% end %>]
  end

  def float_answer?(questions_map, %{source: %{changes: changes}}) do
    get_in(questions_map, [changes.question_id, :answer_type]) == :float
  end

  defp heading(0), do: "Please provide your name and email in start"
  defp heading(_), do: "Please answer the following questions"

  # calculations

  defp calculate_points(%{questions_map: questions_map} = assigns) do
    assigns.changeset
    |> filter_answers(:boolean)
    |> Enum.filter(&(&1.answer == "true"))
    |> Enum.map(&Map.get(questions_map, &1.question_id).points)
    |> Enum.sum()
  end

  defp process_calculation(%{assigns: %{changeset: %{valid?: true} = changeset}} = socket) do
    credit =
      changeset
      |> filter_answers(:float)
      |> Enum.map(& elem(Float.parse(&1.answer), 0))
      |> Enum.sort()
      |> then(fn [elm_1, elm_2] -> (elm_2 - elm_1) * 12 end)

    socket.assigns
    |> calculate_points()
    |> ApprovalClient.credit_score_request()
    |> case do
      {:ok, %{"creditScore" => credit_score}} ->
        send(self(), {:approved, credit_score, credit, changeset.changes.name})
        socket

      {:error, error} ->
        put_flash(socket, :error, "#{error}, try again")
    end
  end

  defp process_calculation(socket), do: socket

  defp filter_answers(changeset, type) do
    changeset
    |> Changeset.apply_changes()
    |> Map.get(:user_answers)
    |> Enum.filter(&(&1.answer_type == type))
  end
end
