defmodule HomepageWeb.Components.CollapsibleSection do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr :title, :string, required: true
  attr :collapsed, :boolean, default: true
  attr :id, :string, required: true
  slot :inner_block, required: true

  def collapsible_section(assigns) do
    ~H"""
    <section class="mb-4 rounded-md shadow-md m-2 p-2">
      <button class="flex gap-4 w-full" type="button" phx-click={toggle_visible(@id)}>
        <div class="flex items-center gap-2">
          <div id={"closed-icon-#{dom_id(@id)}"} class={not @collapsed && "hidden"}>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
              class="w-5 h-5"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zM6.75 9.25a.75.75 0 000 1.5h4.59l-2.1 1.95a.75.75 0 001.02 1.1l3.5-3.25a.75.75 0 000-1.1l-3.5-3.25a.75.75 0 10-1.02 1.1l2.1 1.95H6.75z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
          <div id={"open-icon-#{dom_id(@id)}"} class={@collapsed && "hidden"}>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
              class="w-5 h-5"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm.75-11.25a.75.75 0 00-1.5 0v4.59L7.3 9.24a.75.75 0 00-1.1 1.02l3.25 3.5a.75.75 0 001.1 0l3.25-3.5a.75.75 0 10-1.1-1.02l-1.95 2.1V6.75z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
          <h3 class="font-semibold text-xl text-center"><%= @title %></h3>
        </div>
      </button>
      <div id={dom_id(@id)} class={@collapsed && "hidden"}>
        <%= render_slot(@inner_block) %>
      </div>
    </section>
    """
  end

  def toggle_visible(js \\ %JS{}, id) do
    js
    |> JS.toggle(
      to: dom_selector(id),
      in: {"transition-all duration-200", "opacity-0", "opacity-100"},
      out: {"transition-all duration-200", "opacity-100", "opacity-0"}
    )
    |> JS.toggle(to: "#open-icon-#{dom_id(id)}")
    |> JS.toggle(to: "#closed-icon-#{dom_id(id)}")
  end

  defp dom_id(id), do: "collapsible-#{id}"
  defp dom_selector(id), do: "##{dom_id(id)}"
end
