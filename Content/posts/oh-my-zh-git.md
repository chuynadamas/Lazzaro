---
date: 2021-09-07 21:31
description: A Cheatsheet for some git commands in ohmyzsh 👾
tags: Article, Terminal
---

# Oh my zsh git plugin cheatsheet

If you are using `oh-my-zsh` you can take advantage of some plugins like the `git` one, for this I'll list the most common
commands that I use almost everyday.

## Some useful commands in the [git plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)

<table class="lzz-table">
  <tr class="lzz-tr">
    <th class="lzz-th">Alias</th>
    <th class="lzz-th">Command</th>
    <th class="lzz-th">Notes</th>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gb</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">branch</span></code></td>
    <td class="lzz-td">List all local branches</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gba</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">branch -a</span></code></td>
    <td class="lzz-td">List all local and remote branches</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gcam</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">commit -am</span></code></td>
    <td class="lzz-td">Add all files to stage and commit</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gcmsg</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">commit -m</span></code></td>
    <td class="lzz-td">Git commit message</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gco</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">checkout</span></code></td>
    <td class="lzz-td">Checkout spceified changes</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gco -</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">checkout</span></code></td>
    <td class="lzz-td">Change branch to the previous one</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gd</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">diff</span></code></td>
    <td class="lzz-td">Show differences in staging files/td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gfa</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">fetch --all --prune</span></code></td>
    <td class="lzz-td">Fetch all remote branches, delete branch if upstream is gone</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gl</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">pull</span></code></td>
    <td class="lzz-td">Pull from remote</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gp</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">pull</span></code></td>
    <td class="lzz-td">Push to remote</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gpsup</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">push --set-upstream origin[currentbranch]</span></code></td>
    <td class="lzz-td">Set upstream branch</td>
  </tr>
  <tr class="lzz-tr">
    <td class="lzz-td">gst</td>
    <td class="lzz-td"><code><span class="keyword">git</span> <span class="dotAccess">status</span></code></td>
    <td class="lzz-td">Local files to commit</td>
  </tr>
</table>

<br/>

There are plenty of them, but also you can create new ones open your `.zshrc` file and adding all the alieases that you want in the following format

<br/>

```swift
alias [name]="[command]"
```

<br/>

Let see an example with some of my personal aliases

<br/>

```swift
alias glog="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias glog1="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''"
alias gpullall="git pull --all"
alias gconflict="git diff --diff-filter=U" 
alias gconflict="git diff --name-only --diff-filter=U"
```

<br/>
<br/>

Once you add all the alias that you need, you have to reload the source of your terminal with `source ~/.zshrc` and then you are ready to go! 🐱 && 🐙

<br/>

> Space: the final frontier.  These are the voyages of the starship Enterprise.
Its five-year mission: to explore strange new worlds; to seek out new life
and new civilizations; to boldly go where no man has gone before. 
>  -- <cite>Captain James T. Kirk</cite>