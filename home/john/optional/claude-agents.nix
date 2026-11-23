# Claude Code agent visibility, global for every project:
#   - hooks mark each tmux window with the agent's state (⏳ working, ✅ done, 🔔 needs you)
#     and send a desktop notification when an agent you aren't looking at finishes or blocks
#   - status line shows dir, branch, model, context, session cost and 5h / 7d plan limits
#
# ~/.claude/settings.json stays a normal writable file (Claude Code saves permissions etc.
# there). On each switch only the `hooks` and `statusLine` keys below are merged in with jq
# (`*` deep-merge): every other key is left alone, but a hook event listed here replaces any
# hand-added entries for that same event.
{
  pkgs,
  lib,
  ...
}: let
  agentStatus = pkgs.writeShellApplication {
    name = "claude-agent-status";
    runtimeInputs = with pkgs; [coreutils jq tmux libnotify];
    text = ''
      # Usage: claude-agent-status working|done|input|clear  (hook JSON on stdin)
      # Never fails: a hook error would show up in the Claude transcript.
      state="''${1:-}"
      input=$(cat 2>/dev/null || true)
      [ -n "''${TMUX:-}" ] && [ -n "''${TMUX_PANE:-}" ] || exit 0
      pane="$TMUX_PANE"

      case "$state" in
        working) mark="⏳" ;;
        done) mark="✅" ;;
        input) mark="🔔" ;;
        clear) tmux set -wu -t "$pane" @agent 2>/dev/null || true; exit 0 ;;
        *) exit 0 ;;
      esac
      tmux set -w -t "$pane" @agent "$mark" 2>/dev/null || true

      # Desktop notification only for done/input, and only when that window isn't the
      # one currently shown in an attached session.
      [ "$state" = working ] && exit 0
      visible=$(tmux display -p -t "$pane" '#{&&:#{window_active},#{session_attached}}' 2>/dev/null || echo 0)
      [ "$visible" = 1 ] && exit 0

      cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null || true)
      project=$(basename "''${cwd:-$PWD}")
      where=$(tmux display -p -t "$pane" '#{session_name}:#{window_index} #{window_name}' 2>/dev/null || true)
      if [ "$state" = input ]; then
        body=$(jq -r '.message // "Needs your input"' <<<"$input" 2>/dev/null || echo "Needs your input")
        urgency=critical
      else
        body="Finished"
        urgency=normal
      fi
      notify-send -a "Claude Code" -u "$urgency" "🤖 $project ($where)" "$body" 2>/dev/null || true
      exit 0
    '';
  };

  statusLine = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = with pkgs; [coreutils jq git];
    text = ''
      input=$(cat)
      sep=$'\x1f'
      IFS="$sep" read -r dir model ctx_left cost five five_reset seven <<<"$(jq -r '[
          (.workspace.current_dir // .cwd // ""),
          (.model.display_name // ""),
          (.context_window.remaining_percentage // "" | tostring),
          (.cost.total_cost_usd // "" | tostring),
          (.rate_limits.five_hour.used_percentage // "" | tostring),
          (.rate_limits.five_hour.resets_at // "" | tostring),
          (.rate_limits.seven_day.used_percentage // "" | tostring)
        ] | join("\u001f")' <<<"$input")"

      dim=$'\e[2m' reset=$'\e[0m' yellow=$'\e[33m' red=$'\e[31m'
      pct() {  # colour a 0-100 usage figure: yellow from 70%, red from 90%
        local v
        v=$(printf '%.0f' "$1")
        if [ "$v" -ge 90 ]; then printf '%s%s%%%s' "$red" "$v" "$reset"
        elif [ "$v" -ge 70 ]; then printf '%s%s%%%s' "$yellow" "$v" "$reset"
        else printf '%s%%' "$v"; fi
      }

      out="''${dir/#$HOME/\~}"
      if [ -n "$dir" ] && branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null); then
        out="$out (''${branch:-detached})"
      fi
      [ -n "$model" ] && out="$out ''${dim}|''${reset} $model"
      [ -n "$ctx_left" ] && out="$out ''${dim}|''${reset} ctx $(printf '%.0f' "$ctx_left")% left"
      [ -n "$cost" ] && out="$out ''${dim}|''${reset} \$$(printf '%.2f' "$cost")"
      if [ -n "$five" ]; then
        out="$out ''${dim}|''${reset} 5h $(pct "$five")"
        [ -n "$five_reset" ] && out="$out ''${dim}(resets $(date -d "@$five_reset" +%H:%M))''${reset}"
      fi
      [ -n "$seven" ] && out="$out ''${dim}|''${reset} 7d $(pct "$seven")"
      printf '%s\n' "$out"
    '';
  };

  # Left-hand sidebar listing every tmux window (grouped by session) with its agent marker.
  # One sidebar pane per window, tagged with the pane option @agent_sidebar=1.
  #   claude-agent-sidebar toggle      prefix + g: on/off in every window
  #   claude-agent-sidebar sync        add a sidebar to every window that lacks one (if on)
  #   claude-agent-sidebar add <win>   add one (tmux hooks call this for new windows)
  #   claude-agent-sidebar render      the loop running inside each sidebar pane
  sidebar = pkgs.writeShellApplication {
    name = "claude-agent-sidebar";
    runtimeInputs = with pkgs; [coreutils gawk gnugrep tmux util-linux];
    text = ''
      # A sidebar must never die on a transient tmux error.
      set +o errexit
      self_bin=$(readlink -f "$0")
      sep=$'\x1f'

      is_on() { [ "$(tmux show -gv @agent_sidebar_on 2>/dev/null)" = on ]; }

      add() {
        local win="$1" width pane
        is_on || return 0
        [ -n "$win" ] || return 0
        # Hooks and sync can fire together: serialise so a window never gets two sidebars.
        exec 9>"''${XDG_RUNTIME_DIR:-/tmp}/claude-agent-sidebar.lock"
        flock -w 5 9 || return 0
        tmux list-panes -t "$win" -F '#{@agent_sidebar}' 2>/dev/null | grep -qx 1 && return 0
        width=$(tmux show -gv @agent_sidebar_width 2>/dev/null)
        [[ "$width" =~ ^[0-9]+$ ]] || width=26
        pane=$(tmux split-window -hbf -l "$width" -d -t "$win" -P -F '#{pane_id}' \
          "exec '$self_bin' render" 2>/dev/null) || return 0
        tmux set -p -t "$pane" @agent_sidebar 1 2>/dev/null
      }

      sync() {
        is_on || return 0
        tmux list-windows -a -F '#{window_id}' 2>/dev/null | while read -r w; do add "$w"; done
      }

      kill_all() {
        tmux list-panes -a -F "#{pane_id}$sep#{@agent_sidebar}" 2>/dev/null |
          awk -F "$sep" '$2 == "1" {print $1}' |
          while read -r p; do tmux kill-pane -t "$p" 2>/dev/null; done
      }

      render() {
        # sel_t = the window the j/k cursor is on (by id, so it survives list changes);
        # empty means "this sidebar's own window".
        local self="$TMUX_PANE" own_win width maxw sel_t="" fmt
        own_win=$(tmux display -p -t "$self" '#{window_id}') || exit 0
        fmt="#{session_id}$sep#{session_name}$sep#{window_id}$sep#{window_index}$sep#{pane_active}"
        fmt+="$sep#{@agent_sidebar}$sep#{b:pane_current_path}$sep#{window_name}$sep#{automatic-rename}$sep#{@agent}"
        local bold=$'\e[1m' dim=$'\e[2m' rev=$'\e[7m' reset=$'\e[0m'
        printf '\e[?25l\e[?1000h\e[?1006h\e[2J'  # hide cursor, SGR mouse reporting, clear
        trap 'printf "\e[?1006l\e[?1000l\e[?25h"' EXIT

        while :; do
          # Last real pane in this window closed: exit so the window closes too.
          [ "$(tmux list-panes -t "$self" 2>/dev/null | wc -l)" -gt 1 ] || exit 0
          width=$(tmux display -p -t "$self" '#{pane_width}' 2>/dev/null) || exit 0
          [[ "$width" =~ ^[0-9]+$ ]] || width=26
          # Clamp: a negative substring length is a fatal bash error.
          maxw=$((width > 9 ? width - 7 : 2))

          # One row per window: label = folder of its active real pane, or the window
          # name if you renamed it. Sidebar panes are skipped.
          local -a rows=() wins=() line_target=()
          mapfile -t rows < <(tmux list-panes -a -F "$fmt" 2>/dev/null | awk -F "$sep" -v OFS="$sep" '
            $6 == "1" { next }
            {
              k = $3; l = ($9 == "0") ? $8 : $7
              if (!(k in seen)) { seen[k] = 1; ord[++n] = k; sid[k] = $1; sn[k] = $2; ix[k] = $4; ag[k] = $10; lab[k] = l }
              else if ($5 == "1") lab[k] = l
            }
            END { for (i = 1; i <= n; i++) { k = ord[i]
              if (sn[k] != last) { print "S", "", "", sn[k], ""; last = sn[k] }
              print "W", sid[k] " " k, ix[k], lab[k], ag[k] } }')

          # Windows in display order; resolve the cursor to an index.
          local type tgt idx label agent sel=-1 own_i=0
          for r in "''${rows[@]}"; do
            IFS="$sep" read -r type tgt idx label agent <<<"$r"
            [ "$type" = W ] || continue
            [ "$tgt" = "$sel_t" ] && sel=''${#wins[@]}
            [ "''${tgt#* }" = "$own_win" ] && own_i=''${#wins[@]}
            wins+=("$tgt")
          done
          [ "$sel" -ge 0 ] || sel=$own_i

          local out=$'\e[H'"$bold agents$reset$dim  click / j k ⏎$reset"$'\e[K\n\e[K\n'
          local row=3 wi=0
          for r in "''${rows[@]}"; do
            IFS="$sep" read -r type tgt idx label agent <<<"$r"
            if [ "$type" = S ]; then
              out+="$dim ''${label:0:$((width > 4 ? width - 2 : 2))}$reset"$'\e[K\n'
            else
              local cursor=" " hl=""
              [ "$wi" -eq "$sel" ] && cursor="›"
              [ "''${tgt#* }" = "$own_win" ] && hl="$rev"
              out+="$cursor$hl $(printf '%-2s' "$idx") ''${label:0:$maxw} $reset''${agent:+ $agent}"$'\e[K\n'
              line_target[row]="$tgt"
              wi=$((wi + 1))
            fi
            row=$((row + 1))
          done
          printf '%s\e[J' "$out"

          # Wait up to 1s for a key or click, then redraw.
          local k k2 seq c target="" move=0
          if IFS= read -rsn1 -t 1 k; then
            case "$k" in
              j) move=1 ;;
              k) move=-1 ;;
              "") target="''${wins[$sel]:-}" ;;
              $'\e')
                IFS= read -rsn1 -t 0.05 k2
                if [ "$k2" = "[" ]; then
                  seq=""
                  while IFS= read -rsn1 -t 0.05 c; do
                    seq+="$c"
                    [[ "$c" == [A-Za-z~] ]] && break
                  done
                  case "$seq" in
                    A) move=-1 ;;
                    B) move=1 ;;
                    "<0;"*M)  # left-button press: "<0;x;yM"
                      local y="''${seq##*;}"; y="''${y%M}"
                      target="''${line_target[y]:-}" ;;
                  esac
                fi ;;
            esac
          fi
          if [ "$move" -ne 0 ]; then
            local n=$((sel + move))
            [ "$n" -ge 0 ] && [ "$n" -lt "''${#wins[@]}" ] && sel_t="''${wins[$n]}"
          fi
          if [ -n "$target" ]; then
            # If the sidebar has focus, hand it back to this window's work pane first,
            # so coming back here later doesn't land you in the sidebar.
            [ "$(tmux display -p -t "$self" '#{pane_active}' 2>/dev/null)" = 1 ] &&
              tmux last-pane -t "$self" 2>/dev/null
            tmux switch-client -t "''${target% *}" \; select-window -t "''${target#* }" 2>/dev/null
            sel_t=""
          fi
        done
      }

      case "''${1:-}" in
        add) add "''${2:-}" ;;
        sync) sync ;;
        render) render ;;
        toggle)
          if is_on; then
            tmux set -g @agent_sidebar_on off
            kill_all
          else
            tmux set -g @agent_sidebar_on on
            sync
          fi ;;
        *) echo "usage: claude-agent-sidebar toggle|sync|add <window>|render" >&2; exit 1 ;;
      esac
      exit 0
    '';
  };

  hook = state: [
    {
      hooks = [
        {
          type = "command";
          command = "${agentStatus}/bin/claude-agent-status ${state}";
          timeout = 10;
        }
      ];
    }
  ];

  managedSettings = pkgs.writeText "claude-managed-settings.json" (builtins.toJSON {
    statusLine = {
      type = "command";
      command = "${statusLine}/bin/claude-statusline";
    };
    hooks = {
      SessionStart = hook "clear";
      UserPromptSubmit = hook "working";
      # A tool ran, so any permission prompt was answered: back to working.
      PostToolUse = hook "working";
      Stop = hook "done";
      # idle_prompt is left out: it fires ~60s after Stop and would just re-notify.
      Notification = [
        {
          matcher = "permission_prompt|elicitation_dialog|agent_needs_input";
          hooks = (builtins.head (hook "input")).hooks;
        }
      ];
      SessionEnd = hook "clear";
    };
  });
in {
  home.packages = [agentStatus statusLine sidebar];

  programs.tmux.extraConfig = let
    sb = "${sidebar}/bin/claude-agent-sidebar";
  in ''
    # Show the agent marker after the window name in the tab list: "2:nixos-config ✅*"
    set -g window-status-format "#I:#W#{?@agent, #{@agent},}#{?window_flags,#{window_flags}, }"
    set -g window-status-current-format "#I:#W#{?@agent, #{@agent},}#{?window_flags,#{window_flags}, }"

    # Agent sidebar: on by default, prefix + g toggles it in every window.
    set -g @agent_sidebar_on on
    set -g @agent_sidebar_width 26
    set-hook -g after-new-window[50] 'run-shell -b "${sb} add #{window_id}"'
    set-hook -g after-new-session[50] 'run-shell -b "${sb} add #{window_id}"'
    bind g run-shell -b "${sb} toggle"
    run-shell -b "${sb} sync"
  '';

  home.activation.claudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    claude_settings="$HOME/.claude/settings.json"
    run mkdir -p "$HOME/.claude"
    [ -s "$claude_settings" ] || run sh -c 'echo "{}" > "$1"' _ "$claude_settings"
    claude_tmp=$(mktemp)
    if ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$claude_settings" ${managedSettings} > "$claude_tmp"; then
      if ! cmp -s "$claude_tmp" "$claude_settings"; then
        run cp "$claude_settings" "$claude_settings.bak"
        run cp "$claude_tmp" "$claude_settings"
      fi
    else
      echo "claude-agents: could not merge into $claude_settings (invalid JSON?), left unchanged" >&2
    fi
    rm -f "$claude_tmp"
  '';
}
