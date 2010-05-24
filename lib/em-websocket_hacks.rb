EventMachine::WebSocket::Connection.class_eval do

  def debug(*data)
    if @debug
      data.each do |d|
        Socky.logger.debug "Socket " + d.collect{|dd| dd.to_s.gsub("\r\n","\n").gsub("\n","\\n")}.join(" ")
      end
    end
  end

end