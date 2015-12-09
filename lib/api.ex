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
      
      course_sections = Floki.find(html, "#resulttable tbody tr")

      course_sections
      |> Enum.map(fn section -> 
        #IO.puts section[1]
      end
      )

      # Each Cell/Index
      # (0) Course Section and Course Number, also has URL link to the books
      # relevant to that section in Hammes Bookstore.
      # (1) Title of the course.
      # (2) Number of credits for the course.
      # (3) Status of the course seats (OP for open, CL for closed).
      # (4) Max number of seats.
      # (5) Open number of seats.
      # (6) Cross-Listed?
      # (7) CRN for the course. 
      # (8) Syllabus for the course
      # (9) Instructor for the course!
      # (10) When the course meets, course start time.
      # * Note, these may be prone to having more than one start time, so we
      # have to think of how to show / reflect this in the user interface for
      # various sub-sections. Design flaw on ND's part. -_- 
      # (11) Begin/Start date for the course.
      # (12) End date for the course.
      # (13) Course Location.
      # Also, probably should insert an actual link/reference to the actual
      # course description page...JUST IN CASE, feel me?

      # First Cell - Course Number and Section Number
      {tag, attrs, first_section} = Enum.at(course_sections, 0)
      {_, _, first_cell} = Enum.at(first_section, 0)
      {_, _, course_num_section_text} = Enum.at(first_cell, 0)
      {_, course_books_link_tag, _} = Enum.at(first_cell, 2)
      # Prints out the course number and the section number. O_O
      course_num_section = List.first(course_num_section_text)
      {_, course_books_link} = Enum.at(course_books_link_tag, 0)
      course_books_link
      [course_num, course_section] = String.split(course_num_section," - ", trim: true)
 
      # Second Cell - Course Title
      {_, _, second_cell} = Enum.at(first_section, 1)
      course_title = List.first(second_cell)
      #{_, _, course_title_text} = Enum.at(second_cell, 0)
     
      #course_title = List.first(course_title_text)
      #{_, _, course_title_text} = Enum.at(second_cell, 0)
      #course_title = List.first(course_title_text)

      # Third Cell - Credits
      {_, _, third_cell} = Enum.at(first_section, 2)
      credits = List.first(third_cell) 

      # Fourth Cell - Status
      {_, _, fourth_cell} = Enum.at(first_section, 3)
      status = List.first(fourth_cell)

      # Fifth Cell - Max Seats
      {_, _, fifth_cell} = Enum.at(first_section, 4)
      max_seats = List.first(fifth_cell)

      # Sixth Cell - Open Seats
      {_, _, sixth_cell} = Enum.at(first_section, 5)
      open_seats = List.first(sixth_cell)

      # Seventh Cell - Cross Listed
      {_, _, seventh_cell} = Enum.at(first_section, 6)
      crosslisted = List.first(seventh_cell)

      # Eighth Cell - CRN
      {_, _, eighth_cell} = Enum.at(first_section, 7)
      course_reg_number = String.strip(List.first(eighth_cell))

      # Ninth Cell - Syllabus
      {_, _, ninth_cell} = Enum.at(first_section, 8)
      syllabus = List.first(ninth_cell)

      # Tenth Cell - Instructor
      # May be more than one of these, would be wise to split these on the
      # instances of the anchor tags in this element, for real.
      {_, _, tenth_cell} = Enum.at(first_section, 9)
      instructor = String.strip(List.first(tenth_cell))

      # Eleventh Cell - Timeslots
      # *Note: May have more than one timeslot with the (1).
      # This will probably be reflected as a one-to-many Section to Timeslots
      # in Phoenix.
      # Additionally, gotta split on the timeslots by their start time, end
      # times, and days of the week.
      # Gotta parse this and make the timeslots for real, for reals. u_u 
      {_, _, eleventh_cell} = Enum.at(first_section, 10)
      timeslots = String.strip(List.first(eleventh_cell))

      # Tweltfhh Cell - Begin Date
      # *Note: May have more than one begin date if they have more than one
      # timeslot. :/ Gotta do that some magic here. Luckily, shouldn't be as
      # difficult.
      {_, _, twelfth_cell} = Enum.at(first_section, 11)
      begin_date = String.strip(List.first(twelfth_cell))

      # Thirteenth Cell - End Date
      # *Note: May have more than one end date, ala Timeslots.
      {_, _, thirteenth_cell} = Enum.at(first_section, 12)
      end_date = String.strip(List.first(thirteenth_cell))


      # Fourteenth Cell - Where
      # * Note - May have more than one location, break on splits fam. 
      {_, _, fourteenth_cell} = Enum.at(first_section, 13)
      location = String.strip(List.first(fourteenth_cell))
      
      IO.puts "#{course_num} - #{course_section} - #{course_title}"
      IO.puts "CRN #{course_reg_number}"
      IO.puts "Taught by #{instructor} on #{timeslots}"
      IO.puts "#{credits} credits, #{open_seats}/#{max_seats} seats left"
      IO.puts "Starts #{begin_date} and Ends #{end_date}"
      IO.puts "Location: #{location}"
  end

  @doc """
  Fetches the courses for every single term and department.
  """
  def fetch_all_courses() do 

  end

  def process_course_html(html) do 
  
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

