{
  programs.nushell = {
    enable = true;
    extraConfig = /* nu */ ''
      def create_left_prompt [] {
          let dir = match (do --ignore-errors { $env.PWD | path relative-to $nu.home-path }) {
              null => $env.PWD
              ''' => '~'
              $relative_pwd => ([~ $relative_pwd] | path join)
          }

          let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
          let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
          let path_segment = $"($path_color)($dir)"

          $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
      }

      def create_right_prompt [] {
          # create a right prompt in magenta with green separators and am/pm underlined
          let time_segment = ([
              (ansi reset)
              (ansi magenta)
              (date now | format date '%x %X') # try to respect user's locale
          ] | str join | str replace --regex --all "([/:])" $"(ansi green)''${1}(ansi magenta)" |
              str replace --regex --all "([AP]M)" $"(ansi magenta_underline)''${1}")

          let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
              (ansi rb)
              ($env.LAST_EXIT_CODE)
          ] | str join)
          } else { "" }

          ([$last_exit_code, (char space), $time_segment] | str join)
      }

      def create_title [] {
        let prefix = if SSH_TTY in $env {$"[(hostname | str replace -r "\\..*" "")] "}
        let path = pwd | str replace $env.HOME "~"
        ([$prefix, $path] | str join)
      }

      $env.PROMPT_COMMAND = { || create_left_prompt }
      $env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }
      $env.PROMPT_INDICATOR = {|| "> " }
      $env.PROMPT_INDICATOR_VI_INSERT = {|| "> " }
      $env.PROMPT_INDICATOR_VI_NORMAL = {|| "| " }
      $env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

      let fish_completer = {|spans|
          fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
          | from tsv --flexible --noheaders --no-infer
          | rename value description
          | update value {|row|
            let value = $row.value
            let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
            if ($need_quote and ($value | path exists)) {
              let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
              $'"($expanded_path | str replace --all "\"" "\\\"")"'
            } else {$value}
          }
      }

      $env.config = {
        edit_mode: vi,
        show_banner: false,
        use_kitty_protocol: true,
        shell_integration: {
          osc2: false,
          osc7: true,
          osc8: true,
          osc133: true,
          osc633: true,
          reset_application_mode: true,
        },
        completions: {
          algorithm: "fuzzy",
          external: {
            enable: true,
            completer: $fish_completer,
          },
        },
        history: {
          sync_on_enter: true,
        },
        hooks: {
          pre_prompt: [{
            print -n $"(ansi title)(create_title)(ansi st)"
          }]
        }
      }
    '';
  };
}
