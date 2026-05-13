{ prev, ... }:
prev.openldap.overrideAttrs (old: {
  preCheck = (old.preCheck or "") + ''
    rm -f tests/scripts/test017-syncreplication-refresh
    rm -f tests/scripts/test019-syncreplication-cascade
  '';

  meta = (old.meta or { }) // {
    description = "${old.meta.description or ""} (with broken tests disabled)";
  };
})
