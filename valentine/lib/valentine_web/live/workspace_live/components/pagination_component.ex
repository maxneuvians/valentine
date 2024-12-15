defmodule ValentineWeb.WorkspaceLive.Components.PaginationComponent do
  use Phoenix.Component

  alias PrimerLive.Helpers.AttributeHelpers

  attr(:myself, :any, required: true, doc: "The current live component.")

  attr(:page_count, :integer, required: true, doc: "Result page count.")
  attr(:current_page, :integer, required: true, doc: "Current page number.")

  attr(:link_path, :any,
    required: true,
    doc: """
    Function that returns a path for the given page number. The link builder uses `Phoenix.Component.link/1` with attribute `navigate`. Extra options can be passed with `link_options`.

    Function signature: `(page_number) -> path`
    """
  )

  attr(:side_count, :integer, default: 1, doc: "Number of page links at both ends.")

  attr(:sibling_count, :integer,
    default: 2,
    doc: "Number of page links at each side of the current page number element."
  )

  attr(:is_numbered, :any, default: true, doc: "Boolean atom or string. Showing page numbers.")

  attr(:classes, :map,
    default: %{
      gap: nil,
      pagination_container: nil,
      pagination: nil,
      previous_page: nil,
      next_page: nil,
      current_page: nil,
      page: nil
    },
    doc: """
    Additional classnames for pagination elements. Any provided value will be appended to the default classname.

    Default map:
    ```
    %{
      gap: "",
      pagination_container: "",
      pagination: "",
      previous_page: "",
      next_page: "",
      current_page: "",
      page: ""
    }
    ```
    """
  )

  @default_pagination_labels %{
    aria_label_container: "Pagination navigation",
    aria_label_next_page: "Go to next page",
    aria_label_current_page: "Current page, page {page_number}",
    aria_label_page: "Go to page {page_number}",
    aria_label_previous_page: "Go to previous page",
    gap: "…",
    next_page: "Next",
    previous_page: "Previous"
  }

  attr(:labels, :map,
    default: @default_pagination_labels,
    doc: "Textual labels. Any provided value will override the default text."
  )

  @default_pagination_link_options %{
    replace: false
  }

  attr(:link_options, :map, default: @default_pagination_link_options, doc: "Link options.")

  def pagination(assigns) do
    assigns =
      assigns
      |> assign(:page_count, AttributeHelpers.as_integer(assigns.page_count) |> max(0))
      |> assign(
        :current_page,
        AttributeHelpers.as_integer(assigns.current_page) |> max(1)
      )
      |> assign(
        :side_count,
        AttributeHelpers.as_integer(assigns.side_count) |> AttributeHelpers.minmax(1, 3)
      )
      |> assign(
        :sibling_count,
        AttributeHelpers.as_integer(assigns.sibling_count) |> AttributeHelpers.minmax(1, 5)
      )
      |> assign(
        :is_numbered,
        AttributeHelpers.as_boolean(assigns.is_numbered)
      )
      |> assign(
        :labels,
        Map.merge(@default_pagination_labels, assigns.labels)
      )

    %{
      page_count: page_count,
      current_page: current_page,
      side_count: side_count,
      sibling_count: sibling_count
    } = assigns

    has_previous_page = current_page > 1
    has_next_page = current_page < page_count
    show_numbers = assigns.is_numbered && page_count > 1
    show_prev_next = page_count > 1

    classes = %{
      pagination_container:
        AttributeHelpers.classnames([
          "paginate-container",
          assigns[:classes][:pagination_container],
          assigns[:class]
        ]),
      pagination:
        AttributeHelpers.classnames([
          "pagination",
          assigns[:classes][:pagination]
        ]),
      previous_page:
        AttributeHelpers.classnames([
          "previous_page",
          assigns[:classes][:previous_page]
        ]),
      next_page:
        AttributeHelpers.classnames([
          "next_page",
          assigns[:classes][:next_page]
        ]),
      page:
        AttributeHelpers.classnames([
          assigns[:classes][:page]
        ]),
      current_page:
        AttributeHelpers.classnames([
          assigns[:classes][:current_page]
        ]),
      gap:
        AttributeHelpers.classnames([
          "gap",
          assigns[:classes][:gap]
        ])
    }

    pagination_elements =
      get_pagination_numbers(
        page_count,
        current_page,
        side_count,
        sibling_count
      )

    pagination_container_attrs =
      AttributeHelpers.append_attributes([], [
        ["aria-label": assigns.labels.aria_label_container],
        [role: "navigation"],
        [class: classes.pagination_container]
      ])

    assigns =
      assigns
      |> assign(:pagination_container_attrs, pagination_container_attrs)
      |> assign(:classes, classes)
      |> assign(:show_prev_next, show_prev_next)
      |> assign(:has_previous_page, has_previous_page)
      |> assign(:has_next_page, has_next_page)
      |> assign(:show_numbers, show_numbers)
      |> assign(:pagination_elements, pagination_elements)
      |> assign(:current_page, current_page)

    ~H"""
    <%= if @page_count > 1 do %>
      <nav {@pagination_container_attrs}>
        <div class={@classes.pagination}>
          <%= if @show_prev_next do %>
            <%= if @has_previous_page do %>
              <Phoenix.Component.link
                class={@classes.previous_page}
                rel="previous"
                aria-label={@labels.aria_label_previous_page}
                replace={@link_options.replace}
                phx-click="change_page"
                phx-value-page={@current_page - 1}
                phx-target={@myself}
              >
                <%= @labels.previous_page %>
              </Phoenix.Component.link>
            <% else %>
              <span class={@classes.previous_page} aria-disabled="true" phx-no-format><%= @labels.previous_page %></span>
            <% end %>
          <% end %>
          <%= if @show_numbers do %>
            <%= for item <- @pagination_elements do %>
              <%= if item === @current_page do %>
                <em
                  aria-current="page"
                  aria-label={
                    @labels.aria_label_current_page
                    |> String.replace("{page_number}", to_string(item))
                  }
                  class={@classes.current_page}
                >
                  <%= @current_page %>
                </em>
              <% else %>
                <%= if item == 0 do %>
                  <span class={@classes.gap} phx-no-format><%= @labels.gap %></span>
                <% else %>
                  <Phoenix.Component.link
                    class={@classes.page}
                    aria-label={
                      @labels.aria_label_page |> String.replace("{page_number}", to_string(item))
                    }
                    replace={@link_options.replace}
                    phx-click="change_page"
                    phx-value-page={item}
                    phx-target={@myself}
                  >
                    <%= item %>
                  </Phoenix.Component.link>
                <% end %>
              <% end %>
            <% end %>
          <% end %>
          <%= if @show_prev_next do %>
            <%= if @has_next_page do %>
              <Phoenix.Component.link
                class={@classes.next_page}
                rel="next"
                aria-label={@labels.aria_label_next_page}
                replace={@link_options.replace}
                phx-click="change_page"
                phx-value-page={@current_page + 1}
                phx-target={@myself}
              >
                <%= @labels.next_page %>
              </Phoenix.Component.link>
            <% else %>
              <span class={@classes.next_page} aria-disabled="true" phx-no-format><%= @labels.next_page %></span>
            <% end %>
          <% end %>
        </div>
      </nav>
    <% end %>
    """
  end

  # Get the list of page number elements
  @doc false

  def get_pagination_numbers(
        page_count,
        current_page,
        side_count,
        sibling_count
      )
      when page_count == 0,
      do:
        get_pagination_numbers(
          1,
          current_page,
          side_count,
          sibling_count
        )

  def get_pagination_numbers(
        page_count,
        current_page,
        side_count,
        sibling_count
      ) do
    list = 1..page_count

    # Insert a '0' divider when the page sequence is not sequential
    # But omit this when the total number of pages equals the side_count counts plus the gap item
    may_insert_gaps = page_count !== 0 && page_count > 2 * sibling_count + 1

    case may_insert_gaps do
      true -> insert_gaps(page_count, current_page, side_count, sibling_count, list)
      false -> list |> Enum.map(& &1)
    end
  end

  defp insert_gaps(page_count, current_page, side_count, sibling_count, list) do
    # Prevent overlap of the island with the sides
    # Define a virtual page number that must lay between the boundaries “side + sibling” on both ends
    # then calculate the island
    virtual_page =
      limit(
        current_page,
        side_count + sibling_count + 1,
        page_count - (side_count + sibling_count)
      )

    # Subtract 1 because we are dealing here with array indices
    island_start = virtual_page - sibling_count - 1
    island_end = virtual_page + sibling_count - 1

    island_range =
      Enum.slice(
        list,
        island_start..island_end
      )

    # Join the parts, make sure the numbers a unique, and loop over the result to insert a '0' whenever
    # 2 adjacent number differ by more than 1
    # The result should be something like [1,2,0,5,6,7,8,9,0,99,100]

    side_start_range = Enum.take(list, side_count)
    side_end_range = Enum.take(list, -side_count)

    (side_start_range ++ island_range ++ side_end_range)
    |> MapSet.new()
    |> MapSet.to_list()
    |> Enum.reduce([], fn num, acc ->
      # Insert a '0' divider when the page sequence is not sequential
      previous_num =
        case acc == [] do
          true -> num
          false -> hd(acc)
        end

      acc =
        case num - previous_num > 1 do
          true -> [0 | acc]
          false -> acc
        end

      [num | acc]
    end)
    |> Enum.reverse()
  end

  defp limit(num, lower_bound, upper_bound) do
    min(max(num, lower_bound), upper_bound)
  end
end
