function _golang_normalize_env {
    if [ "${${:-$GO_ENV}[-1]}" = "/" ]; then
        export GO_ENV=${GO_ENV:0:${#GO_ENV}-1}
    elif [ -z "$GO_ENV" ]; then
        export GO_ENV="$HOME/.goenvs";
    fi

    if [ ! -d "$GO_ENV" ]; then
        mkdir "$GO_ENV"
    fi
}

function _golang_workon {
    if [ -z "$1" ]; then
        printf "Specify a workspace to work with\n";
        return 1
    fi

    _golang_normalize_env;
    GOPATH=$(printf "$GO_ENV/$1\n")

    if [ -z "$_GOENV_OLD_PATH" ]; then
        # We have no old path - we can undonditionally set it
        _GOENV_OLD_PATH="$PATH"
    fi

    PATH=$_GOENV_OLD_PATH:$GOPATH/bin

    if [ -d "$GOPATH" ]; then
        export GOPATH
        export PATH
        if [ -n "$GOENV_VERBOSE" ]; then
            printf "GOPATH => %s\nPATH => %s\n" $GOPATH $PATH
        fi
    else
        printf 'No directory found for $GOPATH. Has it been created with 'mk_go_workspace'?\n'
        return 1
    fi
}

alias go_workon=_golang_workon

function mk_go_workspace {
    if [ -z $1 ]; then
        printf "Specify a workspace name\n";
        return 1
    fi

    _golang_normalize_env;

    if [ ! -d $GO_ENV/$1 ]; then
        ws_name=$1;

        pushd $GO_ENV > /dev/null;
        mkdir -p $ws_name/{bin,pkg,src}
        _golang_workon $1
        popd > /dev/null;
    else
        printf "Workspace '$1' already exists!\n"
        return 1
    fi
}

function go_deactivate {
    if [ -n "$_GOENV_OLD_PATH" ]; then
        PATH="$_GOENV_OLD_PATH"
        export PATH
    fi

    unset GOPATH
}
