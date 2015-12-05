defmodule APITest do
  use ExUnit.Case, async: true # Making HTTP requests can be async

  setup do
    #API.initialize
    
    :ok
  end

  test "initialize initializes the API" do 
    {:ok, page} = API.initialize(:apitest)
    html = API.Search.get(:apitest)
    
    assert String.length(html) > 0
  end

  test "fetch_page returns the initial page" do
    html = API.fetch_initial_page()
    assert String.length(html) > 0
  end

  test "fetch_terms returns the terms" do
    terms = API.fetch_terms()
    # Do assertion stuff here.
    # Assert that this is a list or this is a structure?
    # Maybe in the future we will want to return JSON instead?
    # Also, do we want to make sure that every single item in the list has a
    # certain structure as well? That'd be helpful.
    assert is_list(terms)
    assert (length terms) > 0
  end

  test "fetch_departments returns the departments" do
    depts = API.fetch_departments()

    assert is_list(depts)
    assert (length depts) > 0
  end
end
