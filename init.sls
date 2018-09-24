pkgs:
  pkg.installed:
    - pkgs:
      - colordiff
      - git
      - google-chrome-stable
      - pass
      - tilda
      - tmux
      - vim-nox
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
    - name: deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
    - file: /etc/apt/sources.list.d/google-chrome.list
    - gpgcheck: 1
    - key_url: https://dl-ssl.google.com/linux/linux_signing_key.pub
    - refresh: True
    - require:
      - file: pkgs-repo-translation

git-clone-dotfiles:
  git.cloned:
    - name: https://github.com/vando/dotfiles.git
    - target: ~/github/dotfiles
    - require:
      - pkg: pkgs

git-clone-vundle:
  git.cloned:
    - name: https://github.com/VundleVim/Vundle.vim.git
    - target: ~/.vim/bundle/Vundle.vim
    - require:
      - pkg: pkgs

symlink-tmux:
  file.symlink:
    - name: ~/.tmux.conf
    - target: ~/github/dotfiles/ncurses/tmux/tmux.conf.minimal
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-gitconfig:
  file.symlink:
    - name: ~/.gitconfig
    - target: ~/github/dotfiles/ncurses/git/gitconfig
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-gitexcludes:
  file.symlink:
    - name: ~/.gitexcludes
    - target: ~/github/dotfiles/ncurses/git/gitexcludes
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

symlink-vim:
  file.symlink:
    - name: ~/.vimrc
    - target: ~/github/dotfiles/ncurses/vim/vimrc
    - require:
      - pkg: pkgs
      - git: git-clone-dotfiles

vim-plugins:
  cmd.run:
    - only_if: ls -1 ~/.vim/bundle | wc -l | grep '1$'
    - name: vim +PluginInstall +qall
    - require:
      - git: git-clone-vundle
      - file: symlink-vim
