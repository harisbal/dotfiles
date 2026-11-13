function gws-personal --description "gws CLI scoped to the personal Google account"
    env GOOGLE_WORKSPACE_CLI_CONFIG_DIR=$HOME/.config/gws-personal gws $argv
end
