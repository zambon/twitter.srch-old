module TwitterHelper
  
  def parse_tweet_text(text)
    links = text.scan(/((http[s]?\:\/\/|ftp\:\/\/)|(www\.|ftp\.))(\S+)/)
    links.each do |str|
      text = text.sub(
        str[0] + str[3],
        "<a class=\"tlink\" href=\"" + str[0] + str[3] + "\">" + str[0] + str[3] + "</a>"
      )
    end unless links.empty?
    
    #(^|\.|\ |\(|\)|\-|\;|\,|\!|\?|\>|\<|\||\'|\"|\`|\~|\^|\%|\&|\$|\_|\=|\+|\[|\]|\{|\}|\*)
    #/(^|\.|\ )(@\w+)/
    #/(^|\.|\ )(\#\w+)/
    
    users = text.scan(/(^|\.|\ |\(|\)|\-|\;|\,|\!|\?|\>|\<|\||\'|\"|\`|\~|\^|\%|\&|\$|\_|\=|\+|\[|\]|\{|\}|\*)(@\w+)/)
    users.each do |str|
      text = text.sub(
        str[1],
        "@<a class=\"tlink\" href=\"http://twitter.com/" +
          str[1][1, str[1].length] + "\">" +
          str[1][1, str[1].length] + "</a>"
      )
    end unless users.empty?
    
    hashtags = text.scan(/(^|\.|\ |\(|\)|\-|\;|\,|\!|\?|\>|\<|\||\'|\"|\`|\~|\^|\%|\&|\$|\_|\=|\+|\[|\]|\{|\}|\*)(\#\w+)/)
    hashtags.each do |str|
      text = text.sub(
        str[1],
        "<a class=\"tlink\" href=\"http://twitter.com/search?q=%23" +
        str[1][1, str[1].length] + "\" title=\"" + str[1] + "\">" + str[1] + "</a>"
      )
    end unless hashtags.empty?
      
    text
  end
  
  def parse_tweet_time(created_at, from_user)
    Time.parse(created_at).strftime("%a, %d %b %Y, %H:%M")
  end
  
  def parse_tweet_user(from_user)
    "http://twitter.com/" + from_user
  end
  
end
