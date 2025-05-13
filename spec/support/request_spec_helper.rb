module RequestSpecHelper
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end
end
