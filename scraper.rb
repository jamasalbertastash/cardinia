require 'watir'
require 'scraperwiki'

def scrape_page(browser, comment_url)
  table = browser.table(id: 'tbl_results')

  if table.rows.count <= 1
    puts "No table found on the page."
    return
  end

  table.rows(skip: 1).each do |row| # skip the header row
    application_number = row.cells[0].text.strip
    lodged_date = row.cells[1].text.strip
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

url = "https://eplanning.cardinia.vic.gov.au/Public/PlanningRegister.aspx?search=basic&reference=T180314"
comment_url = "mail@cardinia.vic.gov.au"

browser = Watir::Browser.new :chrome, headless: true

# Fetch the initial page
browser.goto(url)

# Find the form and submit the "I Agree" button
agree_button = browser.button(id: 'ctl00_PlaceHolder_Body_btnAcceptDisclaimer')
agree_button.click

# Wait for table to be loaded
Watir::Wait.until { browser.table(id: 'tbl_results').exists? }

puts "Scraping page..."
scrape_page(browser, comment_url)

browser.close
