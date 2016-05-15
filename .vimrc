"neccesary settings


" dein settings {{{
"dein.vimのディレクトリ
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vimがなければgit clone
if &runtimepath !~# '/dein.vim'
    if !isdirectory(s:dein_repo_dir)
        execute '!git clone https://github.com/Shougo/dein.vim'
        s:dein_repo_dir
    endif
    execute 'set runtimepath^=' . s:dein_repo_dir
endif

"設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, ['~/.config/nvim/init.vim', '~/.config/dein/plugins.toml'])

  " 管理するプラグインを記述したファイル
  let s:toml = '~/.config/dein/plugins.toml'
  call dein#load_toml(s:toml, {'lazy': 0})

  call dein#end()
  call dein#save_state()
endif

" その他インストールしていないものはこちらに入れる
if dein#check_install()
  call dein#install()
endif
" }}}
