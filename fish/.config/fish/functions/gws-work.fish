function gws-work --description "gws CLI scoped to the work Google account (transopt.io)"
    env GOOGLE_WORKSPACE_CLI_CONFIG_DIR=$HOME/.config/gws-work gws $argv
end
