TRAPUSR1() {
  if [[ -o INTERACTIVE ]]; then
    {echo; echo "Reloading Zsh config"} 1>&2
    exec "${SHELL}"
  fi
}
