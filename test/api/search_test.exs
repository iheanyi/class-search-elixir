defmodule API.SearchTest do
  use ExUnit.Case, async: true

  test "start_link returns the initial page HTML with the atom name" do
    {:ok, page} = API.Search.start_link(:search)

    html = API.Search.get(:search) 
    assert String.length(html) > 0
  end

  test "start_link with no input still returns the initial page" do
    {:ok, page} = API.Search.start_link
    html = API.Search.get(:initial)
    assert String.length(html) > 0
  end
end
