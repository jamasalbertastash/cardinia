require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

def scrape_page(page, comment_url)
  if table.nil?
  puts "No table found on the page."
  return
end
  table = page.at("#tbl_results")

  table.search("tbody tr").each do |tr|
    application_number = tr.search("td")[0].inner_text.strip
    lodged_date = tr.search("td")[1].inner_text.strip
    decision_date = tr.search("td")[2].inner_text.strip
    address = tr.search("td")[3].inner_text.strip
    reason_for_permit = tr.search("td")[4].inner_text.strip
    ward = tr.search("td")[5].inner_text.strip
    status = tr.search("td")[6].inner_text.strip

    # Convert lodged_date to proper format
    day, month, year = lodged_date.split('-').map(&:to_i)
    lodged_date_formatted = Date.new(year, month, day).to_s

    record = {
      "info_url" => nil,  # No detail page URL provided in the given snippet.
      "comment_url" => comment_url,
      "council_reference" => application_number,
      "description" => reason_for_permit,
      "address" => address,
      "on_notice_to" => lodged_date_formatted,
      "date_scraped" => Date.today.to_s
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
page = agent.get(url)
puts "Scraping page..."
scrape_page(page, comment_url)
