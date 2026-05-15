{
  prev,
  preCheckExtra ? "",
  ...
}:
prev.openldap.overrideAttrs (old: {
  preCheck = (old.preCheck or "") + preCheckExtra;

  meta = (old.meta or { }) // {
    description = "${old.meta.description or ""} (overlay)";
  };
})
