defmodule CreditApprovalWeb.CalculateLive.Index do
  use CreditApprovalWeb, :live_view

  alias CreditApprovalWeb.CalculateLive.Index
  alias CreditApprovalWeb.Live.QuestionComponent

  @currency Application.get_env(:credit_approval, :currency)

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:msg_for, nil)
    |> assign(:start?, false)
    |> ok()
  end

  @impl true
  def handle_event(_event, _params, socket) do
    socket |> assign(:start?, true) |> noreply()
  end

  @impl true
  def handle_info({:not_approved, user_name}, socket) do
    socket
    |> assigns(user_name, :not_approved)
    |> noreply()
  end

  def handle_info({:approved, credit, credit_score, user_name}, socket) do
    socket
    |> assigns(user_name, :approved)
    |> assign(:credit, credit)
    |> assign(:credit_score, credit_score)
    |> noreply()
  end

  def assigns(socket, user_name, msg_for) do
    socket
    |> assign(:msg_for, msg_for)
    |> assign(:user_name, user_name)
    |> assign(:start?, false)
  end

  defp get_button_label(nil), do: "Start"
  defp get_button_label(_), do: "Start Again?"

  @impl true

  def render(assigns) do
    link = Routes.live_path(assigns.socket, Index)

    ~H"""
    <div class="main">
      <%= if @start? do %>
        <%= live_modal @socket, QuestionComponent, id: :new, return_to: link %>
      <% end %>

      <.main {assigns} />
      <%= if @msg_for do %>
        <div class="msg"><.message {assigns} /></div>
      <% end %>
    </div>
    """
  end

  def main(assigns) do
    ~H"""
    <div>
      <h4>Welcome User, We are here to approve your credit</h4>
      <p class="f-w-4">Wondering how to get the approval?</p>
      <p>We provide very simple way to entertain you. Just submit answers
        for couple of questions and that's it <span class="f-w-4">!!!</span>
      </p>

      <div class="flex-container">
          <p>Click on Start button for questioning process</p>
          <button phx-click="start"><%= get_button_label(@msg_for) %></button>
      </div>
    </div>
    """
  end

  def message(%{msg_for: :approved} = assigns) do
    {_currency, sign} = @currency

    ~H"""
      <div>
        <p><span class="msg-s-1">Congratulations <%= @user_name %>, </span>
          you have been approved for credit upto <%= @credit %><span> <%= sign %></span> amount
        </p>
        <p>Your Current Credit Score is <%= @credit_score%></p>
      </div>
    """
  end

  def message(%{msg_for: :not_approved} = assigns) do
    ~H"""
      <div>
        <p><span class="msg-s-1">Thank you, <%= @user_name %> </span>
          for your answers. We are currently unable to issue credit to you.
        </p>
      </div>
    """
  end
end
