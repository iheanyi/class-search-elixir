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
      html = HTTPoison.post!(@base_url,
      "{
        \"TERM\": \"#{term}\",
        \"DIVS\": \"A\",
        \"CAMPUS\": \"M\",
        \"CREDIT\": \"A\",
        \"SUBJ\": \"#{dept}\",
        \"ATTR\": \"0ANY\"
      }",
      [{"Content-Type", "application/x-www-form-urlencoded"}]
    ).body

  end
end

