require 'scraperwiki'
require 'mechanize'

def scrape_page(page, comment_url)
  table = page.at("#tbl_results")

  if table.nil?
    puts "No table found on the page."
    return
  end

  table.search("tbody tr").each do |tr|
    application_number = tr.search("td")[0].inner_text.strip
    lodged_date = tr.search("td")[1].inner_text.strip
    # ... [keeping other fields the same]
    
    # Convert lodged_date to proper format
    day, month, year = lodged_date.split('-').map(&:to_i)
    lodged_date_formatted = Date.new(year, month, day).to_s

    record = {
      # ... [keeping the record hash the same]
    }

    # Check if record already exists
    if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
      puts "Saving record " + record['council_reference'] + ", " + record['address']
      ScraperWiki.save_sqlite(['council_reference'], record)
    else
      puts "Skipping already saved record " + record['council_reference']
    end
  end
end

agent = Mechanize.new

url = "https://eplanning.cardinia.vic.gov.au/Public/PlanningRegister.aspx?search=basic&reference=T180314"
comment_url = "mail@cardinia.vic.gov.au"

# Fetch the initial page
page = agent.get(url)

# Find the form and submit the "I Agree" button
form = agent.page.form_with(id: "aspnetForm")
agree_button = form.button_with(id: "ctl00_PlaceHolder_Body_btnAcceptDisclaimer")
page = agent.submit(form, agree_button)

# Now that you've agreed, re-fetch the page containing the data
page = agent.get(url)
puts "Scraping page..."
scrape_page(page, comment_url)
