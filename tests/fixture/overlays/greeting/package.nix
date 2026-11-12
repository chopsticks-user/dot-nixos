# takes no `prev`: the overlay must not pass it
{ writeShellScriptBin }: writeShellScriptBin "greeting" "echo hi"
