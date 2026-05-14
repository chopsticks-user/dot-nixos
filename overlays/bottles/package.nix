{
  prev,
  removeWarningPopup ? false,
  ...
}:
(prev.bottles.override {
  inherit removeWarningPopup;
}).overrideAttrs
  (old: {
    passthru = (old.passthru or { }) // {
      inherit removeWarningPopup;
    };

    meta = (old.meta or { }) // {
      description = "${old.meta.description or ""} (overlay)";
    };
  })
