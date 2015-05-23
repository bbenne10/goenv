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
        return
    fi

    _golang_normalize_env;
    GOPATH=$(printf "$GO_ENV/$1\n")

    if [ -d "$GOPATH" ]; then
        export GOPATH
    else
        printf 'No directory found for $GOPATH. Has it been created with 'make_go_workspace'?\n'
        return
    fi
}

alias goworkon=_golang_workon

function make_go_workspace {
    if [ -z $1 ]; then
        printf "Specify a workspace name\n";
        return
    fi

    _golang_normalize_env;

    if [ ! -d $GO_ENV/$1 ]; then
        ws_name=$1;

        pushd $GO_ENV > /dev/null;
        mkdir -p $ws_name/{bin,pkg,src}
        _golang_workon $1
        export GOPATH=$PWD/$ws_name
        popd > /dev/null;
    else
        printf "Workspace '$1' already exists!\n"
        return
    fi

}
