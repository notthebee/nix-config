function fish_greeting
  set -l motd_available (which motd)
  if test -n "$motd_available"
    motd
  end
end
