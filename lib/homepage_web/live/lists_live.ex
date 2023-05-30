defmodule HomepageWeb.ListsLive do
  alias Homepage.Repo
  alias HomepageWeb.List
  alias Homepage.SortableList

  use HomepageWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h2>Lists</h2>
      <.live_component
        module={List}
        id="list"
        list={SortableList.get_list!(1) |> Repo.preload(:items)}
      />
    </div>
    """
  end
end
