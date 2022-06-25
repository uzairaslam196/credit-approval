defmodule CreditApprovalWeb.Live.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(CreditApprovalWeb.ModalComponent, modal_opts)
  end

  def noreply(socket), do: {:noreply, socket}

  def ok(socket), do: {:ok, socket}
end
