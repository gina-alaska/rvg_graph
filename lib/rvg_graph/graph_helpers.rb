module RvgGraph::GraphHelpers
  def check_no_data(value, no_data)
    if value.is_a? Numeric
      return true if value == no_data.to_f
    else
      return true if value == no_data
    end

    false
  end
end
