defmodule API.Search do 
  # Investigate whether you can use structures within these Agents.
  # Also, investigate changing the structure of the atom to :'term and
  # department name'. Would be helpful for keeping track of the state of every
  # page without having to refresh.
  @doc """
  Starts the SearchPage with it's initial HTML value.
  """
  def start_link(page \\ :initial) do 
    html = API.fetch_initial_page()
    Agent.start_link(fn -> html end, name: page)
  end

  @doc """
  Get the HTML currently in the `page`.
  """
  def get(page) do
    Agent.get(page, fn html -> html end)
  end
  
  @doc """
  Set the HTML value.
  """
  def set(page) do
    Agent.update(page, fn html -> html end)
  end
end
