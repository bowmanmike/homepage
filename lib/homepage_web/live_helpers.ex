defmodule HomepageWeb.LiveHelpers do
  def noreply(%Phoenix.LiveView.Socket{} = socket), do: {:noreply, socket}

  def reply_ok(%Phoenix.LiveView.Socket{} = socket), do: {:ok, socket}
end
