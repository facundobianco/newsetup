pkgs:
  pkg.installed:
    - pkgs:
      - bc
      - colordiff
      - git
      - google-chrome-stable
      - pass
      - pm-utils
      - python-pygments
      - tilda
      - tmux
      - vim-nox
      - xclip
    - require:
      - pkgrepo: pkgs-repo-chrome

pkgs-minion:
  service.dead:
    - name: salt-minion
    - enable: False

pkgs-repo-translation:
  file.managed:
    - name: /etc/apt/apt.conf.d/99translation
    - contents: 'Acquire::Languages "none";'

pkgs-repo-chrome:
  pkgrepo.managed:
    - name: deb [arch=amd64] http://dl.google.com/linux/chrome/deb stable main
    - file: /etc/apt/sources.list.d/google-chrome.list
    - gpgcheck: 1
    - key_url: https://dl-ssl.google.com/linux/linux_signing_key.pub
    - refresh: True
    - require:
      - file: pkgs-repo-translation

logind:
  service.running:
    - name: systemd-logind
  file.replace:
    - name: /etc/systemd/logind.conf
    - pattern: '^#HandleLidSwitch=.*'
    - repl: 'HandleLidSwitch=ignore'
    - watch_in:
      - service: logind

git-clone-dotfiles:
  git.latest:
    - name: https://github.com/vando/dotfiles.git
    - target: /home/facundo/github/dotfiles
    - user: facundo
    - require:
      - pkg: pkgs

git-clone-vundle:
  git.latest:
    - name: https://github.com/VundleVim/Vundle.vim.git
    - target: /home/facundo/.vim/bundle/Vundle.vim
    - require:
      - pkg: pkgs

symlink-bash-personal:
  file.symlink:
    - name: /etc/profile.d/personal.sh
    - target: /home/facundo/github/dotfiles/ncurses/bash/personal.sh
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-bash-profile:
  file.symlink:
    - name: /home/facundo/.bash_profile
    - target: github/dotfiles/ncurses/bash/bash_profile
    - user: facundo
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-tmux:
  file.symlink:
    - name: /home/facundo/.tmux.conf
    - target: github/dotfiles/ncurses/tmux/tmux.conf.minimal
    - user: facundo
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-gitconfig:
  file.symlink:
    - name: /home/facundo/.gitconfig
    - target: github/dotfiles/ncurses/git/gitconfig
    - user: facundo
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-gitexcludes:
  file.symlink:
    - name: /home/facundo/.gitexcludes
    - target: github/dotfiles/ncurses/git/gitexcludes
    - user: facundo
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-vim:
  file.symlink:
    - name: /home/facundo/.vimrc
    - target: github/dotfiles/ncurses/vim/vimrc
    - user: facundo
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

vim-plugins:
  cmd.run:
    - onlyif: ls -1 /home/facundo/.vim/bundle | wc -l | grep -q '^1$'
    - name: vim +PluginInstall +qall &>/dev/null
    - user: facundo
    - require:
      - git: git-clone-vundle
      - file: symlink-vim
