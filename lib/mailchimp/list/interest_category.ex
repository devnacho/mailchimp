defmodule Mailchimp.List.InterestCategory do
  alias Mailchimp.Link
  alias HTTPoison.Response
  alias Mailchimp.HTTPClient
  alias Mailchimp.List.InterestCategory.Interest

  defstruct [:id, :list_id, :title, :display_order, :type, :links]

  def new(attributes) do
    %__MODULE__{
      id: attributes[:id],
      list_id: attributes[:list_id],
      title: attributes[:title],
      display_order: attributes[:display_order],
      type: attributes[:type],
      links: Link.get_links_from_attributes(attributes)
    }
  end

  def interests(%__MODULE__{links: %{"interests" => %Link{href: href}}}) do
    {:ok, response} = HTTPClient.get(href)
    case response do
      %Response{status_code: 200, body: body} ->
        {:ok, Enum.map(body.interests, &Interest.new(&1))}

      %Response{status_code: _, body: body} ->
        {:error, body}
    end
  end

  def interests!(category) do
    {:ok, interests} = interests(category)
    interests
  end

  def create_interest(%__MODULE__{id: id, list_id: list_id}, attrs \\ %{}) do
    create_interest(id, list_id, attrs)
  end
  def create_interest(id, list_id, attrs ) do
    {:ok, response} = HTTPClient.post("/lists/#{list_id}/interest-categories/#{id}/interests", Poison.encode!(attrs))
    case response do
      %Response{status_code: 200, body: body} ->
        {:ok, Interest.new(body)}

      %Response{status_code: _, body: body} ->
        {:error, body}
    end
  end


end
