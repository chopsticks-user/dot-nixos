# pkgs.seanime-server: seanime with the server flags baked in; the port is exposed for the firewall
{
  prev,
  writeShellApplication,
  port ? 43211,
  ...
}:
writeShellApplication {
  name = "seanime-server";
  text = ''
    exec ${prev.seanime}/bin/seanime --host 0.0.0.0 --port ${toString port} --password encryptlater "$@"
  '';
  passthru = { inherit port; };
}
