function multi_user_brew
  pushd /
  sudo -Hu notthebee brew $argv
  popd
  return
end

