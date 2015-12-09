defmodule API do
  @base_url "https://class-search.nd.edu/reg/srch/ClassSearchServlet"

  @doc """
  Initialize the initial page and everything.
  """
  def initialize(page \\ :initial) do
    API.Search.start_link(page)
  end
  
  @doc """
  Fetches the initial Class Search page.
  """
  def fetch_initial_page do
    # We just want to get the initial URL
    html = HTTPoison.get!(@base_url).body
    
    html
  end

 
  @doc """
  Fetches a list of all the terms, it's lit. 
  """
  def fetch_terms do
    html = fetch_initial_page #API.Search.get(:initial)
    terms = Floki.find(html, "select[name=TERM] option")
    |> Enum.map(fn term -> 
        term_value = Floki.attribute(term, "value")
        |> List.first
        term_name = Floki.text(term)
      
        # Let's return a JSON mapping of all of the terms.
        %{name: term_name, value: term_value}
      end
    ) 

    terms
  end

  @doc """
  Fetches a list of all of the departments.
  """
  def fetch_departments do 
    html = fetch_initial_page
    departments = Floki.find(html, "select[name=SUBJ] option")
    |> Enum.map(fn dept ->
      dept_value = Floki.attribute(dept, "value")
      |> List.first
      dept_name = Floki.text(dept)

      # Let's return a JSON mapping of all the departments and their values.
      %{name: dept_name, value: dept_value}
    end
    )
  end

  @doc """
  Fetches the HTML for the designated term and dept
  """
  def fetch_term_dept_html(term, dept) do
      content_type = %{"Content-type" => "application/x-www-form-urlencoded"}
      html =
      HTTPoison.post!(@base_url,
      {:form , [
          "TERM": "201600",
          "DIVS": "A",
          "CAMPUS": "M",
          "SUBJ": "ACCT",
          "ATTR": "0ANY",
          "CREDIT": "A",
        ]},
        content_type
      ).body

  end

  @doc """
  Fetches the HTML for the first term and department
  """
  def fetch_first() do 
    terms = fetch_terms
    depts = fetch_departments

    first_term = List.first(terms)
    first_dept = List.first(depts)

    fetch_term_dept_html(first_term['value'], first_dept['value'])
  end
end

