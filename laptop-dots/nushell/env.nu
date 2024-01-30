$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
$env.EDITOR = "micro"
$env.VERBOSE_FUNCTIONS = false

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]



def create_left_prompt [] {
    let home =  $nu.home-path

    # Perform tilde substitution on dir
    # To determine if the prefix of the path matches the home dir, we split the current path into
    # segments, and compare those with the segments of the home dir. In cases where the current dir
    # is a parent of the home dir (e.g. `/home`, homedir is `/home/user`), this comparison will 
    # also evaluate to true. Inside the condition, we attempt to str replace `$home` with `~`.
    # Inside the condition, either:
    # 1. The home prefix will be replaced
    # 2. The current dir is a parent of the home dir, so it will be uneffected by the str replace
    let dir = (
        if ($env.PWD | path split | zip ($home | path split) | all { $in.0 == $in.1 }) {
            ($env.PWD | str replace $home "~")
        } else {
            $env.PWD
        }
    )

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X %p') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}




# ALOT OF THIS CODE WAS STOLEN FROM JANE WHOOPS

def debug-print [text] {
    if $env.VERBOSE_FUNCTIONS {
        print $text
    }
}

def list_contains [text, searches] {
    #assume text is a string, and searches is a list
    let has = $searches | split row (char esep) | where ($it == $text)
    (if ($has | is-empty) { false } else { true })
}

def list_exclude [la, lb] {
    #la is the list to remove from
    let excluded = ($la | where (list_contains $it $lb) == false)
    $excluded
}

def does_path_exist [path] {
    let path_has_files = try {
        not (ls $path | is-empty)
    } catch {
        false
    }
    $path_has_files
}

def dirs_not_existing [paths] {
    # no idea WHY i have to invert this again
    $paths | where (not (does_path_exist $it))
}

def insert_if_not_exists [paths] {
    let nhas = $env.PATH | split row (char esep) | where (list_contains $it $paths)
    let needs = list_exclude $paths $nhas
    let dne = dirs_not_existing $paths
    let nne = list_exclude $needs $dne
    debug-print ([$nne] | str join)
    mut thepath = []
    if (($nne | is-empty) != true) {
        debug-print (["need to add: ", $nne] | str join)
        $thepath = ($env.PATH | split row (char esep) | prepend $nne)   
    }
    $thepath
}

let new_path = (insert_if_not_exists [
    '/home/neutron/anaconda3/bin/',
    '/usr/local/bin',
    '/usr/bin',
    '/bin',
    '/usr/local/sbin',
    '/usr/bin/site_perl',
    '/usr/bin/vendor_perl',
    '/usr/bin/core_perl', 
    '/does/not/exist' # here as a litmus test
])
# i do not know if there is an inverse of is-empty, and i also don't care.
if ($new_path | is-empty) != true {
    $env.PATH = $new_path
}


starship init nu | save -f ~/.cache/starship/init.nu


alias ll = ls -la
alias pru = paru
neofetch

use ~/.cache/starship/init.nu
use ~/.config/nushell/conda.nu


