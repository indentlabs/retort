class String
  def capitalize_first
	(slice(0) || '').upcase + (slice(1..-1) || '')
  end

  def capitalize_first!
	replace(capitalize_first)
  end

  def ends_in_terminal_point?
  	#todo handle "quote?"
	['!', '?', '.'].include? (slice(-1) || '')
  end
end