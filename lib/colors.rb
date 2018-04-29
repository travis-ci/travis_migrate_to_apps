module Colors
  COLORS = {
    red:    "\e[31m",
    green:  "\e[32m",
    yellow: "\e[33m",
    blue:   "\e[34m",
    gray:   "\e[37m",
    reset:  "\e[0m"
  }

  def colored(color, str)
    return str if color == :none
    [COLORS[color], str, COLORS[:reset]].join
  end
end
