EventMachine::WebSocket::Connection.class_eval do

  def debug(*data)
    if @debug
      Socky.logger.debug "Socket " + data.flatten.collect{|line| line.to_s.gsub("\r\n","\n").gsub("\n","\\n")}.join(" ")
    end
  end

end