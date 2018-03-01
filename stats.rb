require 'csv'
require 'net/https'
require 'nokogiri'

def get_top_level_posts(link)
  response = Net::HTTP.get(URI(link))
  document = Nokogiri::HTML(response)

  # Top level posts are those inside a <td class="default"> preceded by a
  # <td><img width="0"></td>
  posts = document.css('td.ind > img[width="0"]').map do |node|
    node.parent.css('~ td.default span.c00').text.downcase
  end
end

CSV.open('whoishiring.csv', :headers => true) do |input|
  CSV.open('output.csv', 'w') do |output|
    input.each do |row|
      posts = get_top_level_posts(row['Link'])

      count = posts.map do |post|
        post.scan(/security/).length
      end.inject(0, :+)

      output << [row['Month'], count.to_f / posts.length]
    end
  end
end

