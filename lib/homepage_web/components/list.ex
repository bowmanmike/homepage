defmodule HomepageWeb.List do
  alias Homepage.SortableList
  use HomepageWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div class="space-y-5 mx-auto max-w-xl px-4 space-y-5">
        <.header><%= @list_name %></.header>
        <div class="grid grid-cols-1 gap-2" id={"#{@list_id}-items"} phx-update="stream">
          <div :for={{id, form} <- @streams.items} id={id}>
            <.simple_form
              for={form}
              phx-change="validate"
              phx-submit="save"
              phx-target={@myself}
              class="min-w-0 flex-1 drag-ghost:opacity-0"
              phx-value-id={form.data.id}
            >
              <div class="flex items-center">
                <button
                  :if={form.data.id}
                  type="button"
                  class="w-10"
                  phx-click={JS.push("toggle_complete", target: @myself, value: %{id: form.data.id})}
                >
                  <.icon
                    name="hero-check-circle"
                    class={
                      [
                        "w-7 h-7",
                        if(form[:status].value == :completed,
                          do: "bg-green-600",
                          else: "bg-gray-300"
                        )
                      ]
                      |> Enum.join(" ")
                    }
                  />
                </button>
                <div class="flex-auto text-sm leading-6 text-zinc-900">
                  <input type="hidden" name={form[:list_id].name} value={form[:list_id].value} />
                  <.input
                    field={form[:name]}
                    type="text"
                    phx-target={@myself}
                    phx-key="escape"
                    phx-keydown={
                      !form.data.id &&
                        JS.push("discard", target: @myself, value: %{list_id: @list_id})
                    }
                    phx-blur={form.data.id && JS.dispatch("submit", to: "##{form.id}")}
                  />
                </div>
                <button
                  :if={form.data.id}
                  type="button"
                  class="w-10 -mt-1 flex-none"
                  phx-click={
                    JS.push("delete", target: @myself, value: %{id: form.data.id})
                    |> hide("#list#{@list_id}-item#{form.data.id}")
                  }
                >
                  <.icon name="hero-x-mark" />
                </button>
              </div>
            </.simple_form>
          </div>
        </div>
        <.button phx-click={JS.push("new", target: @myself, value: %{list_id: @list_id})} class="mt-4">
          Add Item
        </.button>
        <.button
          phx-click={JS.push("reset", target: @myself, value: %{list_id: @list_id})}
          class="mt-4"
        >
          Reset
        </.button>
      </div>
    </div>
    """
  end

  def update(%{list: list} = _assigns, socket) do
    item_forms = Enum.map(list.items, &build_item_form(&1, %{list_id: list.id}))

    socket
    |> assign(list_id: list.id, list_name: list.title)
    |> stream(:items, item_forms)
    |> reply_ok()
  end

  def handle_event("new", %{"list_id" => list_id}, socket) do
    socket
    |> stream_insert(:items, build_empty_form(list_id), at: -1)
    |> noreply()
  end

  def handle_event("validate", %{"item" => item_params} = params, socket) do
    item = %SortableList.Item{id: params["id"] || nil, list_id: item_params["list_id"]}
    item_form = build_item_form(item, item_params, :validate)

    socket
    |> stream_insert(:items, item_form)
    |> noreply()
  end

  def handle_event("save", %{"id" => item_id, "item" => params}, socket) do
    todo = SortableList.get_item!(item_id)

    case SortableList.update_item(todo, params) do
      {:ok, updated_item} ->
        socket
        |> stream_insert(socket, :items, build_item_form(updated_item, %{}))

      {:error, changeset} ->
        socket
        |> stream_insert(:items, build_item_form(changeset, %{}, :update))
        |> noreply()
    end
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    case SortableList.create_item(item_params) do
      {:ok, new_item} ->
        empty_form = build_empty_form(item_params["list_id"])

        socket
        |> stream_insert(:items, build_item_form(new_item, %{}))
        |> stream_delete(:items, empty_form)
        |> stream_insert(:items, empty_form)
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(:form, build_item_form(changeset, %{}, :insert))
        |> noreply()
    end
  end

  defp build_empty_form(list_id) do
    build_item_form(%SortableList.Item{list_id: list_id}, %{})
  end

  defp build_item_form(item_or_changeset, params, action \\ nil) do
    changeset = item_or_changeset |> SortableList.change_item(params) |> Map.put(:action, action)

    to_form(changeset, id: "form-#{changeset.data.list_id}-#{changeset.data.id}")
  end
end
