EventMachine::WebSocket::Connection.class_eval do

  def debug(*data)
    if @debug
      data.each do |array|
        Socky.logger.debug "Socket " + array.collect{|line| line.to_s.gsub("\r\n","\n").gsub("\n","\\n")}.join(" ")
      end
    end
  end

end